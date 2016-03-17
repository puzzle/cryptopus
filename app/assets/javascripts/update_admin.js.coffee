$(document).on 'click', '.toggle-button', ->

  if $(this).hasClass("toggle-button-selected")
    message = I18n.admin.users.confirm.disempower
  else
    message = I18n.admin.users.confirm.empower

  user_id = $(this).attr('id');
  url = '/admin/users/' + user_id + '/update_admin';
  if (confirm(message))
    $.ajax({
      type: "POST",
      url: url
    });
    $(this).toggleClass('toggle-button-selected');


