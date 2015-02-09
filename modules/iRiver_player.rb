require 'net/http'
require 'open-uri'
require './helpers'

class IRiverPlayer

  def initialize(options = {})
    @ip = options[:iriver_ip] && !options[:iriver_ip].nil? ? options[:iriver_ip] : `ifconfig -L en0`.scan(/inet.*/)[1].split(" ")[1]
  end

  def run_command(command, options = {})
    subheading = options["Action"] == "Play" ? "Files" : "Playback"
    uri = URI.parse("http://#{@ip}:52199/MCWS/v1/#{subheading}/#{command}?Zone=-1&ZoneType=ID"+ options.map{|key, value| "&#{URI::encode(key.to_s)}=#{URI::encode(value.to_s)}"}.join(""))
    Net::HTTP.get(uri)
  end


  def toggle_play_pause
    run_command("PlayPause")
  end

  def next
    run_command("Next")
  end

  def previous
    run_command("Position", {"Position" => "0"})
    run_command("Previous")
    run_command("Previous")
  end

  def change_volume(setting)
    run_command("Volume", {"Level" => setting})
  end

  def search_track(search)
    run_command("Search", {"Query" => search, "Action" => "Play"})
  end

end

IRIVER_CLIENT = IRiverPlayer.new(iriver_ip: ENV['IRIVER_IP']) if ENV['IRIVER_IP']

def process_iriver(command)
  if c_present?(command, "river")
    if c_present?(command, "volume")
      command = command.gsub("to", "two")
      index = command.index("volume")
      volume = (command[index..-1].in_numbers.to_f)/10.to_f
      IRIVER_CLIENT.change_volume(volume)
    elsif c_present?(command, "next")
      IRIVER_CLIENT.next
    elsif c_present?(command, "previous")
      IRIVER_CLIENT.previous
    elsif c_present?(command, "play") || c_present?(command, "pause") || c_present?(command, "go")
      IRIVER_CLIENT.toggle_play_pause
    elsif c_present?(command, "locate")
      index = command.index("locate")
      search = command[index..-1].gsub("stop", "").gsub("locate", "").strip
      IRIVER_CLIENT.search_track(search)
    end
  end
end

def process_player(command, options = {})
  if options[:player] && options[:player] == "iriver"
    process_iriver(command)
  end
end
