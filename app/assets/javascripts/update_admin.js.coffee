$(document).on('click', '.toggle-button', ( ->
  $(this).toggleClass(' toggle-button-selected');
  user_id = $(this).attr('id');
  url = '/admin/users/' + user_id + '/update_admin';
  $.ajax({
    type: "POST",
    url: url,
    complete: (response, status) ->
      $('.test2').html(response);
      $('.').html("<%= raw render 'layouts/flashes' %>");
  });
));
