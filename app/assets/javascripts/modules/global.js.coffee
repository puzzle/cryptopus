# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.Global
  constructor: () ->
    bind.call()
    
  show_messages = (messages) ->
    return if messages.errors.length == 0 && messages.info.length == 0
    compiled_html = HandlebarsTemplates['alert_messages'](messages)
    $('.message_container').html(compiled_html)

  get_messages = (data) ->
    json_data = jQuery.parseJSON(data.responseText)
    json_data.messages

  bind = ->
      $(document).ajaxComplete (xhr, data) ->
        messages = get_messages(data)
        show_messages(messages) if messages != null
  new Global
