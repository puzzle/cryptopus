# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.ApiUsers
  constructor: () ->
    bind.call()

  show_api_users = () ->
    url = '/api/api_users'
    $.get(url).done (data) ->
      api_users = data['data']['user/apis']
      $('.api-user-row').remove()
      if api_users.length == 0
        $('#api_users_table').remove()
        $('#api_users_title').text('No Api Users')
      else
        template = HandlebarsTemplates['api_users'](api_users)
        $('#api_users_table').append(template)

  bind = ->
    $(document).on 'click', '#profile-api-users-tab', ->
      show_api_users()
  
  new ApiUsers
