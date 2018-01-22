# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.UpdateRole
  constructor: () ->
    bind.call()

  toggle = (url) ->
    $.ajax({
      type: "PATCH",
      url: url
    })

  bind = ->
    $(document).on 'click', '.toggle-button', ->
      user_id = $(this).attr('id')
      url = '/api/admin/users/' + user_id + '/update_role'
      toggle(url)
      $(this).toggleClass('toggle-button-selected')

  new UpdateRole
