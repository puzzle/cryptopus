#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.ToggleApiUser
  constructor: () ->
    bind.call()

  create = (url, id) ->
    $.ajax({
      url: url,
      type: "POST",
      data: {id: id}
    })

  destroy = (url) ->
    $.ajax({
      url: url,
      type: "DELETE"
    })
 
  bind = ->
    $(document).on 'click', '.toggle-button', ->
      api_user_id = $(this).attr('id')
      url = '/teams/' + team_id.value + '/api_users'
      if($(this).hasClass('toggle-button-selected'))
        url += '/' + api_user_id
        destroy(url)
      else
        create(url, api_user_id)
      $(this).toggleClass('toggle-button-selected')

  new ToggleApiUser
