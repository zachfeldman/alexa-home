require 'watir-webdriver'

def keep_alive
  b = Watir::Browser.start 'https://www.amazon.com/ap/signin?openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.assoc_handle=amzn_dp_project_dee&openid.return_to=https%3A%2F%2Fpitangui.amazon.com&'
  email = b.text_field :id => 'ap_email'
  email.exists?
  email.set ENV['AMAZON_EMAIL']
  password = b.text_field :id => 'ap_password'
  password.exists?
  password.set ENV['AMAZON_PASSWORD']
  b.button(:id => "signInSubmit-input").click
  p b.url
  b.goto("http://echo.amazon.com/spa/index.html#settings/dialogs")
  b.execute_script('
    var lastCommand;
    $(document).ajaxComplete(function(){
      command = $(".dd-title.d-dialog-title").first().text()
      if(lastCommand != command){
        $.get("http://localhost:4567/command?q="+command)
        lastCommand = command;
      }
    })
  ')
  sleep(60*15)
  keep_alive
end

keep_alive