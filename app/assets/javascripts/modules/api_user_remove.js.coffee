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
    .html('<div><h5>' + I18n.t('profile.api_users.delete.content', {username: username}))
    .dialog({
      classes: {
          "ui-dialog": 'remove-api-user-dialog'
        }
      modal: true, title: I18n.t('profile.api_users.delete.title'), zIndex: 1000, autoOpen: true,
      width: 'auto', resizable: false,
      buttons: [{
          text: I18n.t('cancel'),
          "class": "btn bnt-primary pull-right",
          click: () ->
            $(this).dialog('close')
       },  {
          text: I18n.t('yes'),
          "class": "btn btn-primary",
          click: () ->
            removeApiUser(elem)
            $(this).dialog('close')
        }],
      close: () ->
        $(this).remove()
      })
    $('.ui-dialog-titlebar-close').hide()

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
