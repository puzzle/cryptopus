 # Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
 # Cryptopus and licensed under the Affero General Public License
 # version 3 or later.
 # See the COPYING file at the top-level directory or at
 # https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Shortcuts
  constructor: () ->
    bind.call()

  search = () ->
    window.location = '/search'

  copyUsername = () ->
    if window.location.href.indexOf("accounts/") > -1
      $('#copy_username_button').click()

  copyPassword = () ->
    if window.location.href.indexOf("accounts/") > -1
      $('#copy_password_button').click()

  bind = ->
    $(document).on 'keydown', (e) ->
      if !e
        e = event
      # search (ctrl + f)
      if e.ctrlKey && e.keyCode==70
        e.preventDefault()
        search()
      # copy username (ctrl + u)
      if e.ctrlKey && e.keyCode==85
        e.preventDefault()
        copyUsername()
      # copy password (ctrl + c)
      if e.ctrlKey && e.keyCode==67
        e.preventDefault()
        copyPassword()

  new Shortcuts
