 # Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
 # Cryptopus and licensed under the Affero General Public License
 # version 3 or later.
 # See the COPYING file at the top-level directory or at
 # https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Shortcuts
  constructor: () ->
    bind.call()

  loginLocation = () ->
    window.location.href.indexOf("login/login") > -1

  login = () ->
    $('.btn').click()

  copyUsername = () ->
    if window.location.href.indexOf("accounts/") > -1
      $('#copy_username_button').click()

  copyPassword = () ->
    if window.location.href.indexOf("accounts/") > -1
      $('#copy_password_button').click()

  openAdminDropdown = () ->
    $('.dropdown-toggle').click()
  
  checkDropdown = () ->
    $('.dropdown.open').length == 1
  
  changeLocation = (location) ->
    window.location = location
  
  bind = ->
    $(document).on 'keydown', (e) ->
      if !e
        e = event
      # search (ctrl + f)
      if e.ctrlKey && e.keyCode==70
        e.preventDefault()
        changeLocation('/search')
      # copy username (ctrl + u)
      if e.ctrlKey && e.keyCode==85
        e.preventDefault()
        copyUsername()
      # copy password (ctrl + c)
      if e.ctrlKey && e.keyCode==67
        e.preventDefault()
        copyPassword()
      # go to teams location (ctrl + shift + t)
      if e.ctrlKey && e.shiftKey && e.keyCode==84
        e.preventDefault()
        changeLocation('/teams')
      # go to change password location (ctrl + shift + c)
      if e.ctrlKey && e.shiftKey && e.keyCode==67
        e.preventDefault()
        changeLocation('/login/show_update_password')
      # open admin dropdown (ctrl + shift + a)
      if e.ctrlKey && e.shiftKey && e.keyCode==65
        e.preventDefault()
        openAdminDropdown()
      # go to admin dropdown location (1-4)
      if e.keyCode==49
        if checkDropdown()
          e.preventDefault()
          changeLocation('/admin/settings/index')
      else if e.keyCode==50
        if checkDropdown()
          e.preventDefault()
          changeLocation('/admin/recryptrequests')
      else if e.keyCode==51
        if checkDropdown()
          e.preventDefault()
          changeLocation('/admin/users')
      else if e.keyCode==52
        if checkDropdown()
          e.preventDefault()
          changeLocation('/admin/maintenance_tasks')
      if e.ctrlKey && e.keyCode==76
        e.preventDefault()
        if loginLocation()
          login()
        else
          changeLocation('/login/logout')

  new Shortcuts
