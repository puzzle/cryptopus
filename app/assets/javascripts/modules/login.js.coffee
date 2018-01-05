# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Login
  constructor: () ->
    bind.call()

  setFocus = ->

    password_input = $('#password')
    user_input = $('#username')
    stored_username = localStorage.getItem('username')
    input_username = user_input.val()

    if stored_username != null and stored_username != ''
      user_input.val stored_username
      password_input.val ''
      password_input.focus()
    else
      user_input.focus()

  selectUsername = ->
    $('#username').select()
    return

  setLocalUsername = ->
    localStorage.setItem 'username', $('#username').val()
    return

  bind = ->
    $(document).on 'page:change', ->
      setFocus()

    $(document).on 'submit', '.login', ->
      setLocalUsername()

    $(document).on 'click', '.logout', ->
      Turbolinks.pagesCached(0)

    $(document).on 'click', '#username', ->
      selectUsername()

  new Login
