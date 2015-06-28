require 'twitter'

class AlexaTwitter

  TWITTER_CLIENT = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  def wake_words
    ["tell the world"]
  end

  def process_command(command)
    TWITTER_CLIENT.update command.gsub("stop", "").gsub("tell the world", "")
  end

end

MODULE_INSTANCES.push(AlexaTwitter.new)