// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//= require jquery
//= require jquery_ujs
//= require zeroclipboard

var auto_logoff_time = 300;
var remaining_seconds = auto_logoff_time+1;

function auto_logoff() {
  if (remaining_seconds <= 1) {
    window.location="/login/logout";
    return;
  }

  remaining_seconds -= 1;
  $('#countdown').html(humanize(remaining_seconds)); 
  setTimeout("auto_logoff()",1000);
}

/**
 * Make seconds human readable.
 */
function humanize(seconds){
  if(seconds > 60) {
  	return Math.ceil(seconds / 60) + "m";
  } else {
  	return seconds + "s"
  }
}

$(document).ready(function(){
  auto_logoff();
});

// Event.observe(window, 'load', auto_logoff, false);



// Password hidden

$(document).ready(function(){
  function selectText(element) {
      var doc = document;
      var text = doc.getElementById(element);    

      if (doc.body.createTextRange) { // ms
          var range = doc.body.createTextRange();
          range.moveToElementText(text);
          range.select();
      } else if (window.getSelection) { // moz, opera, webkit
          var selection = window.getSelection();            
          var range = doc.createRange();
          range.selectNodeContents(text);
          selection.removeAllRanges();
          selection.addRange(range);
      }
  }

  $( ".select-click" ).on( "click", function(e) {
    if (event.target.tagName === 'INPUT') {
      return event.target.select();
    }
  });

  $( ".result-password .password-link" ).on( "click", function(e) {
      e.preventDefault();
      $(this).hide();
      $(this).next(".password-hidden").show();
      selectText(this.id);
  });
});