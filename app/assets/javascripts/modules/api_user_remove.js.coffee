# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.ApiUserRemove
  constructor: () ->
    bind.call()

  noApiUsersContent = () ->
    HandlebarsTemplates['api_users']()

  removeDialog = (elem) ->
    username = $(elem).parents('.api-user-row').children().first().text().trim()

    $('<div></div>').appendTo('body')
    .html('<div class="alert alert-danger delete-api-user"><h5>' + I18n.t('profile.api_users.delete.content', {username: username}) + '</h5></div>')
    .dialog({
      resizable: false,
      draggable: false,
      modal: true,
      width: 'auto',
      classes: {
          'ui-dialog': 'remove-api-user-dialog',
          'ui-dialog-content': 'alert alert-danger'
        },
      buttons: [{
          text: I18n.t('yes'),
          'class': 'btn btn-primary',
          click: () ->
            removeApiUser(elem)
            $(this).dialog('close')
        }, {
          text: I18n.t('cancel'),
          'class': 'btn btn-primary pull-right',
          click: () ->
            $(this).dialog('close')
       }],
      close: () ->
        $(this).remove()
      })
    $('.ui-dialog-titlebar').hide()

  removeApiUser = (elem) ->
    $.ajax({
      type: "DELETE",
      url: '/api/api_users/' +id(elem)
      success: (data) ->
        if(isLastElement())
          content = noApiUsersContent()
          $("#api_user_content").replaceWith(content)
        else
          $(elem).parents('.api-user-row').remove()
      })

  isLastElement = ->
    $('#api_users_table tr').length == 2

  id = (elem) ->
    $(elem).parents('.api-user-row').attr('id')


  bind = ->
    $(document).on 'click', '#remove-user', (e) ->
      e.preventDefault()
      removeDialog(this)

  new ApiUserRemove
