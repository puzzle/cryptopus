# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||={}

class app.UpdateRole
  constructor: () ->
    bind.call()

  update_role = (url, role) ->
    $.ajax({
      type: "PATCH",
      url: url,
      data: { role: role }
    })

  bind = ->
    $(document).on 'click', '.dropdown-item', ->
      user_id = $(this).parents('.btn-group').attr('id')
      user_role = $(this).closest('li').attr('val')
      url = '/api/admin/users/' + user_id + '/update_role'
      $(this).parents('.btn-group').find('.dropdown-toggle').text($(this).text())
      update_role(url, user_role)

  new UpdateRole
