//  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
//  Cryptopus and licensed under the Affero General Public License version 3 or later.
//  See the COPYING file at the top-level directory or at
//  https://github.com/puzzle/cryptopus.

var AUTO_LOGOFF_TIME = 300;
var remaining_seconds = AUTO_LOGOFF_TIME;

function auto_logoff() {
  if (remaining_seconds <= 1) {
    window.location="/login/logout";
    return;
  }

  remaining_seconds -= 1;
  $('#countdown').html(humanize(remaining_seconds));
  setTimeout("auto_logoff()",1000);
}

// Make seconds human readable.
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


$(document).on('page:load', function() {
  remaining_seconds = AUTO_LOGOFF_TIME;
});
