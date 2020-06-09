# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.ApiUserToggle
  constructor: () ->
    bind.call()

  toggleLocked = (elem) ->
    user_id = id(elem)
    selected = 'toggle-button-selected'
    toggle = $(elem)
    if(toggle.hasClass(selected))
      unlockApiUser(user_id)
      toggle.removeClass(selected)
    else
      console.log("befor")
      lockApiUser(user_id)
      toggle.addClass(selected)

  lockApiUser = (id) ->
    $.ajax({
      method: 'POST',
      data: {},
      url: '../api/api_users/' + id + '/lock',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log(jqXHR)
        console.log(textStatus)
        console.log(errorThrown)
      success: (data, textStatus, jqXHR) ->
        console.log(data)
    });

  unlockApiUser = (id) ->
    $.ajax({
      method: 'DELETE',
      url: '../api/api_users/' + id + '/lock',
    })

  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')

  bind = ->
    $(document).on 'click', '#active-api-user', (e) ->
      e.preventDefault()
      toggleLocked(this)

  new ApiUserToggle
