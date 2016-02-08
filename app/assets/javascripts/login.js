//  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
//  Cryptopus and licensed under the Affero General Public License version 3 or later.
//  See the COPYING file at the top-level directory or at
//  https://github.com/puzzle/cryptopus.

var password_input = $('#password');
var user_input = $('#username');

$(document).ready(function() {
  var stored_username = localStorage.getItem('username');

  if (stored_username != null && stored_username != ""){
    user_input.val(stored_username);
    password_input.val('')
    password_input.focus();
  } else {
    user_input.focus();
  }
});

$('.login').submit(function createLocalStorageEntry() {
  var input_username = user_input.val();
  localStorage.setItem('username', input_username);
});

user_input.click(function() {
  user_input.select();
});