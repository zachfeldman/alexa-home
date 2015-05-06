require 'google/api_client'
require 'google/api_client/auth/installed_app'
require 'JSON'
require 'chronic'
require 'titleize'

class AlexaGoogleCalendar

  def wake_words
    ["add event"]
  end

  TIMES = {
    'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4', 'five' => '5', 'six' => '6',
    'seven' => '7', 'eight' => '8', 'nine' => '9', 'ten' => '10', 'eleven' => '11', 'twelve' => '12',
    'thirteen' => '13', 'fourteen' => '14', 'fifteen' => '15', 'sixteen' => '16', 'seventeen' => '17',
    'eighteen' => '18', 'nineteen' => '19', 'twenty' => '20', 'thirty' => '30', 'forty' => '40', 'fifty' => '50'
  }

  def process_command(command)
    # Create a client if one doesn't already exist
    client ||= Google::APIClient.new(
      application_name: 'Alexa Calendar',
      application_version: '0.0.0'
    )

    # Check to see if client_secrets file exists.
    if client.authorization.client_id.nil? && File.file?('modules/google_calendar/client_secrets.json')
      client_secrets = Google::APIClient::ClientSecrets.load('modules/google_calendar/client_secrets.json')
      @authorization = Signet::OAuth2::Client.new(
        authorization_uri: client_secrets.authorization_uri,
        token_credential_uri: client_secrets.token_credential_uri,
        client_id: client_secrets.client_id,
        client_secret: client_secrets.client_secret,
        redirect_uri: client_secrets.redirect_uris.first,
        scope: 'https://www.googleapis.com/auth/calendar'
      )
    else
      p "You'll need a client_secrets token before proceeding"
    end

    # Load access tokens locally, or through web if not stored locally.
    if File.file?('modules/google_calendar/client_authorization.json') && client.authorization.access_token.nil?
      File.open('modules/google_calendar/client_authorization.json', 'r') do |file|
        tokens = JSON.load(file)
        @authorization.access_token = tokens['access_token']
        @authorization.refresh_token = tokens['refresh_token']
      end
      client.authorization = @authorization

    elsif !File.file?('modules/google_calendar/client_authorization.json') && client.authorization.access_token.nil?
      # Run installed application flow.
      flow = Google::APIClient::InstalledAppFlow.new(
        client_id: client_secrets.client_id,
        client_secret: client_secrets.client_secret,
        scope: ['https://www.googleapis.com/auth/calendar']
      )
      client.authorization = flow.authorize

      # Now write the file with refresh and access tokens
      open('modules/google_calendar/client_authorization.json', 'w+') { |f| f.write(client.authorization.to_json) }
    end

    calendar ||= client.discovered_api('calendar', 'v3')

    # Add event to calendar
    begin
      entry = parse_time(command)
      latest = client.execute(api_method: calendar.events.quick_add, parameters: { 'calendarId' => 'primary', 'text' => entry })
    rescue Faraday::SSLError => e
      puts "Error: #{e}"
      client.authorization.fetch_access_token!
      puts 'Retrying...'
      latest = client.execute(api_method: calendar.events.quick_add, parameters: { 'calendarId' => 'primary', 'text' => entry })
    rescue Faraday::ConnectionFailed => n
      puts "Error: #{n}"
    else
      puts "Adding #{command} to your calendar"
      puts 'Event added!' if latest.success?
    end
  end

  private

  def parse_time(command)
    # Commands must include the word "google" - or whatever the triger word is set to.
    # Here we change time in words to standard hour:minute format
    # This greatly increases the accuracy of Google's quick add feature.

    replace_time = command.rpartition(/at /)[-1].split(' ').map { |e| e if TIMES.keys.include?(e) }

    if replace_time.include?(nil)
      replace_time = replace_time[0...replace_time.index(nil)]
    end

    time = replace_time.map { |t| t = TIMES[t] }

    if command.downcase.scan(/evening|night|afternoon|dinner/).length > 0
      modifier = 'p.m.'
    elsif command.downcase.scan(/morning/).length > 0
      modifier = 'a.m.'
    else modifier = ''
    end

    complexity = time.compact.length
    if complexity == 1
      time = time.compact.join(' ') + ':00'
    elsif complexity == 2
      time = time.join(' ').gsub(/\s+/, ':')
    elsif complexity == 3
      time = time.shift + ':' + (time[0].to_i + time[1].to_i).to_s
    end

    if time.length > 0
      time = (Chronic.parse(time + ' ' + modifier).strftime('%H:%M'))
      command.gsub!(replace_time.join(' '), time)
    end

    command.gsub!('add event', '').titleize!
  end

end

MODULE_INSTANCES.push(AlexaGoogleCalendar.new)