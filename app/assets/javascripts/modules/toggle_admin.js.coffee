# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.ToggleAdminHandler
  constructor: () ->

  toggle = (url) ->
    $.ajax({
      type: "POST",
      url: url
    });


  bind: ->
    $(document).on 'click', '.toggle-button', ->
      user_id = $(this).attr('id');
      url = '/admin/users/' + user_id + '/toggle_admin';
      toggle(url)
      $(this).toggleClass('toggle-button-selected');



new app.ToggleAdminHandler().bind()
