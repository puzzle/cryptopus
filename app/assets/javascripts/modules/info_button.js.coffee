# Copyright (c) 2008-2016, Puzzle ITC GmbH.
# This file is part of Cryptopus and licensed
# under the Affero General Public License
# version 3 or later. See the COPYING file
# at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.InfoButton
  constructor: () ->
    bind.call()

  infoTimeout = ->
    $('.private').css 'display', 'inline'
    setTimeout (->
      $('.private').hide()
      return
    ), 10000
    return


  bind = ->
    $(document).on 'click', '.private_info', ->
      infoTimeout()

  new InfoButton
