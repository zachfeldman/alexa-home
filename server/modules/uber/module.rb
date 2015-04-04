require './helpers'

require 'uber_api'
require 'geocoder'

# "give me a cab to union square new york new york stop"

class AlexaUber

  def wake_words
    ["cab to"]
  end

  def process_command(command)
    if command_present?(command, "cab to")

      real_ride = ENV['UBER_REAL_RIDE']

      parsed_location = command.gsub("stop", "").split("cab to")[1].chop.strip

      # You'll need an UBER_SERVER_TOKEN and an UBER_BEARER_TOKEN
      # Don't know how to set environment variables? See:
      # http://nycda.com/blog/using-environment-variables-to-safely-store-api-credentials/
      client = Uber::Client.new(
        :server_token => ENV['UBER_SERVER_TOKEN'],
        :bearer_token => ENV['UBER_BEARER_TOKEN'],
        :sandbox => !real_ride
      )

      location_1 = get_location(ENV['UBER_DEFAULT_LOCATION'])
      location_2 = get_location(parsed_location)

      # Default to UberX
      product_choices = client.products(location_1[:lat].to_f, location_1[:lon].to_f)
      product_id = product_choices[0]["product_id"]

      # Create the ride request
      ride = client.request({
        :product_id => product_id,
        :start_latitude => location_1[:lat],
        :start_longitude => location_1[:lon],
        :end_latitude => location_2[:lat],
        :end_longitude => location_2[:lon]
      })

    end
  end


  private

  # Geocode the pickup location into latitude and longitude
  def get_location(location)
    location_request = Geocoder.search(location)
    if location_request.count != 1
      p "Couldn't locate your location."
    else
      location_lat = location_request[0].data["geometry"]["location"]["lat"]
      location_lon = location_request[0].data["geometry"]["location"]["lng"]
      {lat: location_lat, lon: location_lon}
    end
  end

end

MODULE_INSTANCES.push(AlexaUber.new)