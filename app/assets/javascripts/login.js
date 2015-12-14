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
  user_input.val('');
});