# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License
# version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.
app = window.App ||= {}

class app.AccountForm

  constructor: () ->
    bind.call()

  generatePassword = () ->
    password_field = $('#account_password')
    password_field.val(randomPassword(12))

  randomPassword = (length) ->
    PASSWORD_CHARS = 'abcdefghijklmnopqrstuvwxyz!@#$%^&*()-+<>ABCDEFGHIJKLMNOP1234567890'
    pass = ''
    x = 0
    while x < length
      i = Math.floor(Math.random() * PASSWORD_CHARS.length)
      pass += PASSWORD_CHARS.charAt(i)
      x++
    pass

  bind = ->
    $(document).on 'click', '#random_password', ->
      generatePassword()

  new AccountForm
