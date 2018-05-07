# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.ApiUsers
  constructor: () ->
    bind.call()

  options = [
      { name: 'One minute', value: 60},
      { name: 'Five minutes', value: 300},
      { name: 'Twelve hours', value: 43200},
      { name: 'Infinite', value: 0}
    ]

  api_users_data = (data) ->
    debugger
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
        $('#api_users_table').remove()
        $('#api_users_title').text('No Api Users')
      else
        show_api_users(api_users)

  api_users_template = (api_users) ->
    initValidFor(api_users, options)
    HandlebarsTemplates['api_users'](api_users: api_users, options: options)


  show_api_users = (api_users) ->
    template = api_users_template(api_users)
    $('#api_users_table').append(template)

  initValidFor = (api_users, options) ->
    api_users.forEach (api_user) ->
      options.forEach (elem) ->
        if elem.value == api_user.valid_for
          api_user.valid_text = elem.name

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
        $('#api_users_table').append(api_users_template(api_user))
                             .fadeIn()
    })


  updateApiUser = (id, data) ->
    $.ajax({
      type: "PATCH",
      url: '/api/api_users/' +id,
      data: data
    })

  updateApiUserValidFor = (user_id, valid_for) ->
    data = { user_api: { valid_for: valid_for } }
    updateApiUser(user_id, data)

  updateApiUserDescription = (user_id, description) ->
    data = { user_api: { description: description } }
    updateApiUser(user_id, data)

  renewApiUser = (id) ->
    $.ajax({
      type: "GET",
      url: '/api/api_users/' + id + '/token'
    })

  removeApiUser = (id) ->
    $.ajax({
      type: "DELETE",
      url: '/api/api_users/' +id
    })

  removeDialog = (elem) ->
    $('<div></div>').appendTo('body')
    .html('<div><h5> Delete Api-User ' + $(elem).parents('.api-user-row').children().first().text().trim() + '?')
    .dialog({
      modal: true, title: 'Remove Api-User', zIndex: 1000, autoOpen: true,
      width: 'auto', resizable: false,
      buttons: {
        Yes: () ->
          removeApiUser(id(elem))
          $(this).dialog('close')
          $(elem).parents('.api-user-row').remove()
        No: () ->
          $(this).dialog('close')
      },
      close: () ->
        $(this).remove()
      })


  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')

  bind = ->
    $(document).on 'click', '#profile-api-users-tab', ->
      load_api_users()

    $(document).on 'click', '#dropdown_valid_for', (e) ->
      e.preventDefault()
      valid_for = $(this).closest('li').attr('val')
      updateApiUserValidFor(id(this), valid_for)
      $(this).parents('.dropdown').find('.dropdown-toggle span:first').text($(this).text())

    $(document).on 'click', '.api-user-description', ->
      user_id = id(this)
      replaceWith = $('<input id="hiddenFied_'+user_id+'" type="text" />')
      if($(this).text().trim()!='click to enter description..')
        replaceWith.val($(this).text().trim())
      elem = $(this)
      elem.hide()
      elem.after replaceWith
      replaceWith.focus()
      replaceWith.blur ->
        if $(this).val() != ''
          description = $(this).val()
          updateApiUserDescription(id(this), description)
          elem.text($(this).val())
        $(this).remove()
        elem.show()

    $(document).on 'click', '#create_api_user_button', (e) ->
      e.preventDefault()
      url = '/api/api_users'
      create_api_user(url)

    $(document).on 'click', '#renew-user', (e) ->
      e.preventDefault()
      user_id = id(this)
      renewApiUser(user_id)

    $(document).on 'click', '#remove-user', (e) ->
      e.preventDefault()
      removeDialog(this)

  new ApiUsers
