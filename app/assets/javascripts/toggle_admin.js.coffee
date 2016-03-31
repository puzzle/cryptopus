$(document).on 'click', '.toggle-button', ->
  user_id = $(this).attr('id');
  url = '/admin/users/' + user_id + '/toggle_admin';
  $.ajax({
    type: "POST",
    url: url
  });
  $(this).toggleClass('toggle-button-selected');
