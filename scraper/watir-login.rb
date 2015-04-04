require 'watir-webdriver'

class AlexaCrawler

  attr_accessor :browser
  attr_accessor :last_command

  SETTINGS_URL = "http://echo.amazon.com/spa/index.html#settings/dialogs"
  LOGIN_URL = 'https://www.amazon.com/ap/signin?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.assoc_handle=amzn_dp_project_dee&openid.return_to=https%3A%2F%2Fpitangui.amazon.com&'
  REFRESH_TIME_IN_MINUTES = 32

  def initialize
    self.browser = Watir::Browser.new
    self.last_command = ""
    super
  end

  def kill
    browser.close
  end
  
  def keep_alive

    if browser.url == SETTINGS_URL
      old_browser = self.browser
      self.browser = Watir::Browser.new 
    end

    browser.goto LOGIN_URL


    email = browser.text_field id: 'ap_email'
    email.wait_until_present
    email.set ENV['AMAZON_EMAIL']

    password = browser.text_field id: 'ap_password'
    password.set ENV['AMAZON_PASSWORD']

    browser.button(id: "signInSubmit-input").click

    browser.goto SETTINGS_URL

    if old_browser
      self.last_command = old_browser.spans(class:"dd-title").first.text
      old_browser.close
    end

    browser.execute_script("
      var lastCommand = '"+last_command+"';
      $(document).ajaxComplete(function(){
        command = $('.dd-title.d-dialog-title').first().text()
        if(lastCommand != command){
          $.get('http://localhost:4567/command?q='+command)
          lastCommand = command;
        }
      })
    ")

    sleep(60*REFRESH_TIME_IN_MINUTES)
    keep_alive
  end

end

def start_crawler(last_command = "")
	begin
		a = AlexaCrawler.new	
    a.last_command = last_command
		a.keep_alive
	rescue => error
    p "Error: #{error}"
		last_command = a.last_command
		a.kill
		start_crawler(last_command)
	end
end

start_crawler