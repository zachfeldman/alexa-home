var lastCommand;
$(document).ajaxComplete(function(){
  command = $(".dd-title.d-dialog-title").first().text()
  if(lastCommand != command){
    $.get("http://localhost:4567/command?q="+command)
    lastCommand = command;
  }
})