# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions

#= require i18n/translations

app = window.App ||= {}

class app.ApiUsers
  constructor: () ->
    bind.call()

  scope = 'profile.api_users.options'

  api_users_data = (data) ->
    api_users = data['data']['user/apis']
    if(!api_users)
      api_users = [data['data']['user/api']]
    api_users

  load_api_users = () ->
    url = '/api/api_users'
    $.get(url).done (data) ->
      api_users = api_users_data(data)
      $('.api-user-row').remove()
      if api_users.length == 0
        hideTable()
      else
        $('#no_api_users').attr('hidden', true)
        show_api_users(api_users)

  api_users_template = (api_users) ->
    HandlebarsTemplates['api_users'](api_users: api_users)

  apiUsersTable = (apiUsers) ->
    HandlebarsTemplates['api_users'](api_users: api_users)

  apiUserRow = (apiUser) ->

  hideTable = () ->
    $('#api_users_table').hide()
    $('#no_api_users').attr('hidden', false)

  isFirst = () ->
    $('#api_users_title').text().trim() == 'No Api Users'

  showTable = () ->
    $('#no_api_users').attr('hidden', true)
    $('#api_users_table').show()

  show_api_users = (api_users) ->
    template = api_users_template(api_users)
    $('#api_users_table').append(template)

  create_api_user = (url) ->
    $.ajax({
      url: url,
      method: 'POST',
      data: {
        user_api: {
          description: ''
          valid_for: '60'
        }
      }
      success: (data) ->
        api_user = api_users_data(data)
        if(isFirst())
          showTable()

        $('#api_users_table').append(api_users_template(api_user))
                             .fadeIn()
    })

  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')

  bind = ->
    $(document).on 'click', '#profile-api-users-tab', ->
      load_api_users()

    $(document).on 'click', '#create_api_user_button', (e) ->
      $('#no_api_users').attr('hidden', true)
      e.preventDefault()
      url = '/api/api_users'
      create_api_user(url)

  new ApiUsers
