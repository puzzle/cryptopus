# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.FlashMessage
  @flash_messages = []

  constructor: () ->

  show_flash_message = ->
    for messages in @flash_messages
      $('#alert_js').style.display = 'block'
      $('#alert_message').innerHTML = message
      setTimeout (->
        document.getElementById('alert_js').style.display = 'none'
        return
      ), 10000
      return

  render_messages = ->
    content = HandlebarsTemplates['alert_messages']('test')
    $('.message_container').html(content)

  hide_alert_block = ->
    document.getElementById('alert_js').style.display = 'none'
    return

  @add_message: (message) ->
    @flash_messages.push message
    render_messages()

  bind: ->
    $(document).on 'click', '.close', ->
      hide_alert_block()

new app.FlashMessage().bind()
