// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require prototype
//= require effects
//= require controls
//= require rails
//= require dragdrop

var auto_logoff_time = 10800;
var remaining_seconds = auto_logoff_time+1;

function auto_logoff() {
  if (remaining_seconds <= 1) {
    window.location="/login/logout";
    return;
  }

  remaining_seconds -= 1;
  $('countdown').update(remaining_seconds); 
  setTimeout("auto_logoff()",1000);
}

Event.observe(window, 'load', auto_logoff, false);  

