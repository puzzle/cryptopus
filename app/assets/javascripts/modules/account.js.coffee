# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AccountHandler
  constructor: () ->

  checkIfFunctioningBrowser = ->
    ie10andbelow = navigator.userAgent.indexOf('MSIE') != -1 or /MSIE 10/i.test(navigator.userAgent) or /rv:11.0/i.test(navigator.userAgent)
    if(ie10andbelow)
      $('.clip_button_account').remove()
    else
      new ZeroClipboard( $('.clip_button_account') )

  showPassword = (e) ->
    passLink = $(e.target)
    passInput = passLink.next('.password-hidden')
    passLink.hide()
    passInput.removeClass('hide')

    setTimeout (->
      passInput.select()
      return
    ), 80

    setTimeout (->
      passLink.show()
      passInput.addClass 'hide'
      return
    ), 5000

  bind: ->
    $(document).on 'ready', ->
      checkIfFunctioningBrowser()
    $(document).on 'click', '.result-password .password-link', (e) ->
      showPassword(e)

new app.AccountHandler().bind()
