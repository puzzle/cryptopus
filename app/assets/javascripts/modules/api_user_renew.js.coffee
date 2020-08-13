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
        $.ajax({
          type: "GET",
          url: '/api/api_users/' + id,
          success: (data) ->
            api_user = data['data']['attributes']
            row = $('.api-user-row#' + id)
            timestamp = validUntil(api_user)
            updateTimestamp(row, timestamp)
            updateLocked(row)
        })
    })

  updateTimestamp = (row, timestamp) ->
    elem = row.children().find('#valid_until')
    elem.text(timestamp)

  updateLocked = (row) ->
    elem = row.children().find('#active-api-user')
    selected = 'toggle-button-selected'
    if(elem.hasClass(selected))
      elem.removeClass(selected)

  validUntil = (api_user) ->
    if(api_user.valid_for == 0)
      ''
    else
      api_user.valid_until

  clipCcliToken = (id) ->
    $.ajax({
      type: "GET",
      url: '/api/api_users/' + id + '/ccli_token',
      success: (data) ->
        navigator.clipboard.writeText("ccli login #{data['base_url']} --token #{data['ccli_token']}")
    })

  bind = ->
    $(document).on 'click', '#renew-user', (e) ->
      e.preventDefault()
      user_id = id(this)
      renewApiUser(user_id)
    $(document).on 'click', '#clip-ccli-token', (e) ->
      e.preventDefault()
      user_id = id(this)
      clipCcliToken(user_id)

  new ApiUserRenew
