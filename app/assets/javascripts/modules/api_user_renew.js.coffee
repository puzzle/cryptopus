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
      url: '/api/api_users/' + id + '/token',
      success: (data) ->
        api_user = data['data']['user/api']
        timestamp = validUntil(api_user)
        updateTimestamp(id, timestamp)
    })

  updateTimestamp = (id, timestamp) ->
    elem = $('.api-user-row#' + id).children().find('#valid_until')
    elem.text(timestamp)

  validUntil = (api_user) ->
    if(api_user.valid_for == 0)
      ''
    else
      api_user.valid_until

  bind = ->
    $(document).on 'click', '#renew-user', (e) ->
      e.preventDefault()
      user_id = id(this)
      renewApiUser(user_id)

  new ApiUserRenew
