# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License
# version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.
app = window.App ||= {}

class app.GeneratePassword
  constructor: () ->
    bind.call()

  generate = () ->
    password_field = $('.generatable_password')
    password_field.val(randomPassword())

  randomPassword = () ->
    buffer = new Uint8Array(30)
    window.crypto.getRandomValues(buffer)
    btoa(String.fromCharCode.apply(null, buffer))

  bind = ->
    $(document).on 'click', '#generate_button', ->
      generate()

  new GeneratePassword
