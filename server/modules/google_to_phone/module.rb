require 'watir-webdriver'
require 'yaml'

SEARCH_URL = "www.google.com/webhp?nomo=1&hl=en&gws_rd=ss"
PIN_NUMBERS = {
  'zero' => 0, 'one' => '1', 'two' => '2', 'three' => '3', 'four' => '4', 'five' => '5', 'six' => '6',
  'seven' => '7', 'eight' => '8', 'nine' => '9'
}
SAVED_SESSION = File.dirname(File.expand_path(__FILE__)) + '/google_to_phone.cookies.yaml'

class GoogleToPhone

	def wake_words
		["google"]
	end

  attr_accessor :browser

	def authorize(command)
		if File.file?(SAVED_SESSION)
			my_cookies = YAML::load(File.open(SAVED_SESSION, 'r')) 
			self.browser.cookies.clear
				my_cookies.each do |saved_cookie|
					self.browser.cookies.add(saved_cookie[:name], saved_cookie[:value], :expires => saved_cookie[:expires], :path => saved_cookie[:path], :secure => saved_cookie[:secure])
				end
		browser.refresh
		browser.goto(SEARCH_URL)
		else 
			pin = command.split(' ').collect { |n| PIN_NUMBERS[n] if PIN_NUMBERS.keys.include?(n) }
			self.browser.goto("http://accounts.google.com")
			self.browser.text_field(:name => 'Email').set ENV[GOOGLE_EMAIL]
			self.browser.text_field(:name => 'Passwd').set ENV[GOOGLE_PASSWORD]
			self.browser.button(:name => 'signIn').when_present.click
				if self.browser.text_field(:name => 'smsUserPin').exist?
					self.browser.text_field(:name => 'smsUserPin').set(pin)
					self.browser.button(:id => 'smsVerifyPin').click
				end
			save_cookies
		end
	end

	def save_cookies
		my_cookies = self.browser.cookies.to_a
		File.open(SAVED_SESSION, 'w') { |f| f.write my_cookies.to_yaml }
		puts "cookies saved!"
	end

	def note_to_self(command)
		self.browser. text_field(:name => 'q').set "note to self #{command} \n"
		sleep(1)
		self.browser.span(:text => "Send note to your phone").click
		if self.browser.div(:text => "Check your phone's notifications").exist?
			puts "Note Sent!"
		end
	end

	def reminder(command)
		self.browser.text_field(:name => 'q').set "remind me to #{command} \n"
		self.browser.span(:text => "Remind me on Google Now").wait_until_present
		self.browser.span(:text => "Remind me on Google Now").click
		self.browser.wait(2)
		if self.browser.div(:class => "act-scs-img").exist?
			puts "Reminder Set!"
		end
	end

	def directions(command)
		self.browser.text_field(:name => 'q').value=("send directions\n")
		self.browser.text_field(:placeholder => "Where do you want to go?").wait_until_present
		self.browser.text_field(:placeholder => "Where do you want to go?").value=("#{command}")
		self.browser.text_field(:placeholder => "Where do you want to go?").click
		self.browser.send_keys(:return)
		self.browser.text_field(:placeholder => "Where do you want to go?").click
		self.browser.span(:text => "Send directions to my phone").click
		if self.browser.div(:text => "Directions sent").exist?
			puts "Directions Sent!"
		end
	end

	def process_address(command)
		command = command.partition(/to/).slice!(-1,command.index("to"))[0]
		command.gsub!('to', 'two')
		address = (command.split(' ').each do |n| n.gsub!(n, PIN_NUMBERS[n]) if PIN_NUMBERS.include?(n) end).partition { |m| PIN_NUMBERS.values.include?(m) }
		address[0].join(' ').delete(' ') + ' ' + address[1].join(' ')
	end

	def process_command(command)
		command.gsub!('google', '')
			begin
				self.browser ||= Watir::Browser.new
				self.browser.wait(3)
				self.browser.goto(SEARCH_URL)
					if !self.browser.div(:text => ENV[GOOGLE_EMAIL).exist?
						authorize(command)
					end
			rescue => error
				puts "#{error}"
				self.browser = Watir::Browser.new
				self.browser.goto(SEARCH_URL)
				authorize(command)
			end
		if command.include?('remind me to')
			command.gsub!('remind me to','')
			reminder(command)
		elsif command.include?('directions to')
			command = process_address(command)
			directions(command)
		elsif command.include?('note')
			command.gsub!('note', '')
			note_to_self(command)
		end
	end
end

MODULE_INSTANCES.push(GoogleToPhone.new)

