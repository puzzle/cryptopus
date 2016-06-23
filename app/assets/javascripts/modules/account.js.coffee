# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Account
  constructor: () ->
    bind.call()

  showPassword = (e) ->
    passLink = $(e.target)
    passInput = passLink.next('.password-hidden')
    passLink.hide()
    $('.result-password').css 'top', '0px'
    $('.result-password').css 'padding-bottom', '48px'
    passInput.removeClass('hide')
    setTimeout (->
      passInput.select()
      return
    ), 80

    setTimeout (->
      $('.result-password').css 'top', '-48px'
      $('.result-password').css 'padding-bottom', '0px'
      passLink.show()
      passInput.addClass 'hide'
      return
    ), 5000

  copyContent = ->
    new Clipboard('.clip_button_account')

  @showMessage: (e, name) ->
    par = $(e.target.closest(name)).parent()
    if $(par).hasClass('result-password select-click')
        message = '<p class="copied" >Password copied! </p>'
        div = '.result-password'
    else
        message = '<p class="copied" >Username copied! </p>'
        div = '.result-username'
    $(message).appendTo div
    par.find($('.copied')).fadeIn('fast')
    setTimeout (->
      $(div).find($('.copied')).fadeOut('fast')
      $(div).find($('.copied')).remove()
      return
    ), 2000

  ready = ->
    copyContent()

  bind = ->
    $(document).on 'page:load', ready
    $(document).ready(ready)
    $(document).on 'click', '.password-link', (e) ->
      showPassword(e)
    $(document).on 'click', '.clip_button_account', (e)->
      app.Account.showMessage(e, '.clip_button_account')


  new Account
