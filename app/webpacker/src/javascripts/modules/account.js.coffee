# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Account
  constructor: () ->
    bind.call()

  showPassword = (password_link) ->
    password_input = password_link.next('.password-hidden')
    result_password = password_link.next('.result-password')
    result_password.css 'top', '0px'
    result_password.css 'padding-bottom', '48px'
    password_input.removeClass('hide')
    setTimeout (->
      password_input.select()
      return
    ), 80

    setTimeout (->
      $('.result-password').css 'top', '-48px'
      $('.result-password').css 'padding-bottom', '0px'
      password_link.show()
      password_input.addClass 'hide'
      return
    ), 5000

  copyContent = ->
    new Clipboard('.clip_button')

  ready = ->
    copyContent()

  bind = ->
    $(document).on 'page:load', ready
    $(document).ready(ready)
    $(document).on 'click', '.password-link', (e) ->
      e.preventDefault()
      $(this).hide()
      password_link = $(this)
      showPassword(password_link)

    $(document).on 'click', '.clip_button', (e) ->
      app.AccountHelper.showCopyMessage(e, '.clip_button')

    $(document).on 'click', '.result-username input', (e) ->
      $(this).select()

  new Account
