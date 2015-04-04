require 'color'

DEFAULT_SATURATION = 220

class RGB

  attr_reader :red, :green, :blue

  def initialize(r, g, b)
    @red = r.to_f / 255
    @green = g.to_f / 255
    @blue = b.to_f / 255
    @max = [@red, @green, @blue].max
    @min = [@red, @green, @blue].min
  end
  
  def to_hsl
    l = self.luminance
    s = self.saturation
    h = self.hue
    HSL.new(h, s, l)
  end

  def to_hue
    to_hsl.to_hue
  end

  def to_hex
    "#{@red.to_s(16)}#{@green.to_s(16)}#{@blue.to_s(16)}"
  end

  def luminance
    @luminance ||= 0.5 * (@max + @min)
  end

  def saturation
    self.luminance unless @luminance
    if @max == @min
      @saturation ||= 0
    elsif @luminance <= 0.5
      @saturation ||= (@max - @min) / (2.0 * @luminance)
    else
      @saturation ||= (@max - @min) / (2.0 - 2.0 * @luminance)
    end
  end

  def hue
    if @saturation.zero?
      @hue ||= 0
    else
      case @max
      when red
        @hue ||= (60.0 * ((@green - @blue) / (@max - @min))) % 360.0
      when green
        @hue ||= 60.0 * ((@blue - @red) / (@max - @min)) + 120.0
      when blue
        @hue ||= 60.0 * ((@red - @green) / (@max - @min)) + 240.0
      end
    end
  end
end

class HexRGB < RGB
  def initialize(hex)
    @hex = hex
    hex = hex.scan(/../).map { |e| e.to_i(16) }
    super(hex[0], hex[1], hex[2])
  end

  def to_rgb
    hex = @hex.scan(/../).map { |e| e.to_i(16) }
    [hex[0], hex[1], hex[2]]
  end
end

def rgb_to_hsl(colors)
  red, green, blue = colors[0] / 255.0, colors[1] / 255.0, colors[2] / 255.0

  max = [red, green, blue].max
  min = [red, green, blue].min
  h, s, l = 0, 0, ((max + min) / 2 * 255)

  d = max - min
  s = max == 0 ? 0 : (d / max * 255)

  h = case max
      when min
        0 # monochromatic
      when red
        (green - blue) / d + (green < blue ? 6 : 0)
      when green
        (blue - red) / d + 2
      when blue
        (red - green) / d + 4
      end * 60  # / 6 * 360

  h = (h * (65536.0 / 360)).to_i
  [h, s.to_i, 1.0]
end

def string_to_hue(string)
  basic_color_hues = {red: 65280, pink: 56100, blue: 46920, green: 25500, yellow: 12750}
  if basic_color_hues.keys.include?(string.to_sym)
    colors = []
    colors[0]
    directive = {hue: basic_color_hues[string.to_sym], saturation: DEFAULT_SATURATION}
  else
    hex = Color::CSS[string].html
    colors = rgb_to_hsl(HexRGB.new(hex).to_rgb)
    directive = {hue: colors[0], saturation: colors[1]}
  end
  return directive
end