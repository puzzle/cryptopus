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
    return if messages.errors == undefined && messages.info == undefined
    translated_messages = {info: [], errors: []}
    translated_messages.info = (I18n.t(message) for message in messages.info)
    translated_messages.errors = (I18n.t(message) for message in messages.errors)
    compiled_html = HandlebarsTemplates['alert_messages'](messages)
    $('.message_container').html(compiled_html)

  get_messages = (data) ->
    json_data = jQuery.parseJSON(data.responseText)
    if json_data.messages?
      return json_data.messages
    else
      return json_data

  bind = ->
      $(document).ajaxComplete (xhr, data) ->
        messages = get_messages(data)
        show_messages(messages) if messages != null
  new Global
