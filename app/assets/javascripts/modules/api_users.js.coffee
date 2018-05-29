# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of # Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions

app = window.App ||= {}

class app.ApiUsers
  constructor: () ->
    bind.call()

  scope = 'profile.api_users'

  initialize = (data) ->
    apiUsers = apiUsersData(data)
    content = apiUsersContent(apiUsers)
    renderContent(content)

  initializeRow = (data) ->
    apiUser = apiUsersData(data)
    row = apiUserRows(apiUser)
    appendRow(row)

  apiUsersData = (data) ->
    apiUsers = data['data']['user/apis']
    if(!apiUsers)
      apiUsers = [data['data']['user/api']]
    apiUsers

  apiUsersContent = (apiUsers) ->
    HandlebarsTemplates['api_users'](api_users: apiUsers)

  apiUserRows = (apiUser) ->
    Handlebars.partials['_api_user_row'](api_users: apiUser)

  renderContent = (content) ->
    if $('#api_user_content').length == 0
      $("#api_users").append(content)
    else
      $("#api_user_content").replaceWith(content)

  appendRow = (row) ->
    $('#api_users_table_body').append(row)

  isFirst = () ->
    $('#api_users_table_body').length == 0

  loadApiUsers = () ->
    url = '/api/api_users'
    $.get(url).done (data) ->
      initialize(data)

  createApiUser = (url) ->
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
        if(isFirst())
          initialize(data)
        else
          initializeRow(data)
    })

  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')

  bind = ->
    $(document).on 'click', '#profile-api-users-tab', ->
      loadApiUsers()

    $(document).on 'click', '#create_api_user_button', (e) ->
      $('#no_api_users').attr('hidden', true)
      e.preventDefault()
      url = '/api/api_users'
      createApiUser(url)

  new ApiUsers
