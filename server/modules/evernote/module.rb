require 'evernote_oauth'
require 'chronic'

# You'll need a developer token. Visit: https://www.evernote.com/api/DeveloperToken.action
TOKEN = 'Your Developer Token Here'
TIMES = {
    ' a' => '1', 'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4', 'five' => '5', 'six' => '6',
    'seven' => '7', 'eight' => '8', 'nine' => '9', 'ten' => '10', 'eleven' => '11', 'twelve' => '12',
    'thirteen' => '13', 'fourteen' => '14', 'fifteen' => '15', 'sixteen' => '16', 'seventeen' => '17',
    'eighteen' => '18', 'nineteen' => '19', 'twenty' => '20', 'thirty' => '30', 'forty' => '40', 'fifty' => '50'
  }

REMINDER_TIMES = /at #{Regexp.union(TIMES.keys)}|at \d|today|tonight|morning|evening|afternoon|midnight|tomorrow|monday|tuesday|wednesday|thursday|friday|saturday|sunday|january|february|march|april|may|june|july|august|september|october|november|december|(#{Regexp.union(TIMES.keys)}) (minutes?|hours?|days?|weeks?|months?) .*?from|next (week|month|year)|in \w+ ?\w+ (minutes?|hours?|days?|weeks?|months?|years?).*$/
CLIENT = EvernoteOAuth::Client.new(token: TOKEN, sandbox: false)

class AlexaEvernote

  def wake_words
    ["remind me to"]
  end

  def process_command(command)
    command.gsub!('remind me to', '')
    if command.match(REMINDER_TIMES).nil?
      reminder_time = Time.now
      create_reminder(command, reminder_time)
    else
      parse_time(command)
      body = command.slice(0...command =~ /(\d+.?.?\d+.?)?#{REMINDER_TIMES}/).strip
      reminder_time = set_reminder_time(command, body)
      create_reminder(body, reminder_time)
    end
  end

  private

  def parse_time(command) # converts compound times in words (eight forty five) to HH:MM format that Chronic can understand
    replace_time = command.rpartition(/at /)[-1].split(' ').map { |e| e if TIMES.keys.include?(e) }
    if replace_time.include?(nil)
      replace_time = replace_time[0...replace_time.index(nil)]
    end

    time = replace_time.map { |t| t = TIMES[t] }

    complexity = time.compact.length
    if complexity == 1
      time = time.compact.join(' ') + ':00' 
    elsif complexity == 2
      time = time.join(' ').gsub(/\s+/, ':')
    elsif complexity == 3
      time = time.shift + ':' + (time[0].to_i + time[1].to_i).to_s
    end

    if time =~ /\d/
      time = command.gsub!(replace_time.join(' '), time)         
    else
      time = command
    end
  end

  def set_reminder_time(command, body)
    time = command.gsub(body,'').strip
    time.sub!(/^on|^at/, '')
    Chronic.parse(time)
  end

  def create_reminder(body, reminder_time)
    body.sub!(/at$|on$|this$|in$/,'')
    body.strip
  
    note_store = CLIENT.note_store
    user_store = CLIENT.user_store

  	note = Evernote::EDAM::Type::Note.new
  	note.title = "Alexa Reminder"
  	note.content = '<?xml version="1.0" encoding="UTF-8"?>'
    note.content += '<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">'
  	note.content += "<en-note>#{body}</en-note>"
  	
  	# init NoteAttributes instance
  	note.attributes = Evernote::EDAM::Type::NoteAttributes.new
  	note.attributes.reminderOrder = Time.now.to_i * 1000
  	note.attributes.reminderTime = reminder_time.to_i * 1000
  	 
  	created_note = note_store.createNote(note)
  	 
  	puts "Note created with GUID: #{created_note.guid}"
  end
end

MODULE_INSTANCES.push(AlexaEvernote.new)
