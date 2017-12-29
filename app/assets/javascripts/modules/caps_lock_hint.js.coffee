# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License
# version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.CapsLockHint
  constructor: () ->
    bind.call()

  showHint = () ->
    $('#password').popover('show')

  hideHint = () ->
    $('#password').popover('hide')

  bind = ->
    $(document).on 'keypress', '#password', (e) ->
      # c = character
      c = String.fromCharCode(e.which)
      if c.toUpperCase() == c && c.toLowerCase() != c && !e.shiftKey
        showHint()
      else
        hideHint()
    $(document).on 'blur', '#password', ->
      hideHint()

  new CapsLockHint
