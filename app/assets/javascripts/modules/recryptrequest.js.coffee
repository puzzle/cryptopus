# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Recryptrequest
  constructor: () ->
    bind.call()

  forgotPassword = (check_box) ->
    if(check_box.checked)
      $('#old_password').prop('disabled', true);
      $('#recrypt_description').fadeIn()
    else
      $('#old_password').prop('disabled', false);
      $('#recrypt_description').hide()

  bind = ->
    $(document).on 'change', '#forgot_password', ->
      forgotPassword(this)

  new Recryptrequest