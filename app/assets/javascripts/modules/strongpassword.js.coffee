# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Strongpassword
  constructor: () ->
    bind.call()


  callback = (username, password, strength)->
    img = $(password).next('img.strength')
    if !img.length
      $(password).after '<img class=\'strength\'>'
      img = $('img.strength')
    $(img).removeClass('weak').removeClass('good').removeClass('strong').addClass(strength.status).attr 'src', $.strength[strength.status + 'Image']
    $('b').remove('#strength_status')
    $(img).after("<b id='strength_status'>#{strength.status}</b>")
    return



  showStrength = ->
    $.strength.weakImage = "/assets/weak.png"
    $.strength.goodImage = "/assets/good.png"
    $.strength.strongImage = "/assets/strong.png"
    $.strength "#hidden_username", "#new_password1", callback
    $.strength '#account_cleartext_username', '#account_cleartext_password', callback

  bind = ->
    $(document).on 'page:change', showStrength

  new Strongpassword
