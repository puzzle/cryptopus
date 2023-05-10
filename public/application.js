setFocus = () => {
  password_input = document.getElementById("#password");
  user_input = document.getElementById("username");
  stored_username = sessionStorage.getItem("username");
  input_username = user_input.val();
  if (stored_username != null && stored_username != "") {
    user_input.val(stored_username);
    password_input.val("");
    password_input.focus();
  } else if (input_username == "root") {
    password_input.focus();
  } else {
    user_input.focus();
  }
};

selectUsername = () => {
  document.getElementById("username").select();
  return;
};

document.addEventListener("DOMContentLoaded", function (event) {
  document.addEventListener("page:change", setFocus);
  const usernameElement = document.getElementById("username");

  if (typeof(usernameElement) != 'undefined' && usernameElement != null) {
    usernameElement.addEventListener("click", selectUsername);
  }
});


