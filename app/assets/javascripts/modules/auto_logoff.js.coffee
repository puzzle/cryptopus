# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Auto_logoff
  timer =
  AUTO_LOGOFF_TIME = 300

  constructor: () ->

  auto_logoff = (remaining_seconds, start_time) ->
    if document.URL.indexOf('/login/login') > -1
      return
    if remaining_seconds <= 1
      window.location = '/login/logout'
      return
    remaining_seconds -= 1
    $('#countdown').html humanize(remaining_seconds)
    timer = setTimeout ( -> auto_logoff(remaining_seconds)), 1000
    return

  # Make seconds human readable.

  humanize = (seconds) ->
    if seconds > 60
      Math.ceil(seconds / 60) + 'm'
    else
      seconds + 's'

  new_timer = ->
    clearTimeout(timer)
    auto_logoff(AUTO_LOGOFF_TIME)

  bind: ->
    $('.login').on 'submit', ->
      new_timer()

    $(document).on 'page:change', ->
      new_timer()

    $(document).ready(new_timer)


new app.Auto_logoff().bind()
