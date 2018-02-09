# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.ResetPassword
  constructor: () ->
    bind.call()

  reset_password = () ->
    $('#reset_password_screen').dialog
      autoOpen: false
      modal: true
      width: 600
      height: 300
      resizable: false
    $('.ui-widget-header').hide()
    $('#reset_password_screen').dialog('open')
    $('.alert-danger.reset-password').show()
    $('#delete_user_button').prop('disabled', false)

  bind = ->
    $(document).on 'click', '.reset_password_button', (e) ->
      e.preventDefault()
      reset_password()
    
    $(document).on 'click', '#reset_password_cancel_button', (e) ->
      $('#reset_password_screen').dialog 'close'

    $(document).on 'click', '#reset_password_submit_button', (e) ->
      $('#reset_password_form').submit()

  new ResetPassword
