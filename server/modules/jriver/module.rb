require 'net/http'
require 'open-uri'
require './helpers'

class AlexaIRiverPlayer

  def initialize
    env_iriver_ip = ENV['IRIVER_IP'] if ENV['IRIVER_IP']
    @ip = env_iriver_ip  && !env_iriver_ip .nil? ? env_iriver_ip : `ifconfig -L en0`.scan(/inet.*/)[1].split(" ")[1]
  end

  def wake_words
    ["river"]
  end

  def process_command(command)
    if command_present?(command, "river")
      if command_present?(command, "volume")
        command = command.gsub("to", "two")
        index = command.index("volume")
        volume = (command[index..-1].in_numbers.to_f)/10.to_f
        change_volume(volume)
      elsif command_present?(command, "next")
        next_song
      elsif command_present?(command, "previous")
        previous
      elsif command_present?(command, "play") || command_present?(command, "pause") || command_present?(command, "go")
        toggle_play_pause
      elsif command_present?(command, "locate")
        index = command.index("locate")
        search = command[index..-1].gsub("stop", "").gsub("locate", "").strip
        search_track(search)
      end
    end
  end


  private

  def run_command(command, options = {})
    subheading = options["Action"] == "Play" ? "Files" : "Playback"
    uri = URI.parse("http://#{@ip}:52199/MCWS/v1/#{subheading}/#{command}?Zone=-1&ZoneType=ID"+ options.map{|key, value| "&#{URI::encode(key.to_s)}=#{URI::encode(value.to_s)}"}.join(""))
    Net::HTTP.get(uri)
  end


  def toggle_play_pause
    run_command("PlayPause")
  end

  def next_song
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

MODULE_INSTANCES.push(AlexaIRiverPlayer.new)