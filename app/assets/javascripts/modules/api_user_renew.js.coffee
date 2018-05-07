# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.ApiUserRenew
  constructor: () ->
    bind.call()

  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')

  renewApiUser = (id) ->
    $.ajax({
      type: "GET",
      url: '/api/api_users/' + id + '/token'
    })

  bind = ->
    $(document).on 'click', '#renew-user', (e) ->
      e.preventDefault()
      user_id = id(this)
      renewApiUser(user_id)

  new ApiUserRenew
