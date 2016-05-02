# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AccountHandler
  constructor: () ->

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

  showMessage = (e) ->
      $(e.target).next('.copied').fadeIn('fast')
      setTimeout (->
        $(e.target).next('.copied').fadeOut('fast')
        return
      ), 2000
      return

  ready = ->
    copyContent()

  bind: ->
    $(document).on 'page:load', ready
    $(document).ready(ready)
    $(document).on 'click', '.password-link', (e) ->
      showPassword(e)
    $(document).on 'click', '.clip_button_account', (e)->
      showMessage(e)

new app.AccountHandler().bind()
