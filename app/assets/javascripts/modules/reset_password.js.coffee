# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.ResetPassword
  constructor: () ->
    bind.call()

  reset_password = () ->
    $.ui.dialog.prototype._focusTabbable = ->
    $('#reset_password_screen').dialog
      resizable: false
      modal: true
      autoOpen: false
    $('.ui-widget-header').hide()
    $('#reset_password_screen').dialog('open')

  bind = ->
    $(document).on 'click', '.reset_password_button', (e) ->
      e.preventDefault()
      reset_password()
    
    $(document).on 'click', '#reset_password_cancel_button', (e) ->
      $('#reset_password_screen').dialog 'close'

    $(document).on 'click', '#reset_password_submit_button', (e) ->
      $('#reset_password_form').submit()

  new ResetPassword
