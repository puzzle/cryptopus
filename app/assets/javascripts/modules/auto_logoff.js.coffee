# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AutoLogoff
  AUTO_LOGOFF_TIME = 300
  remaining_seconds = AUTO_LOGOFF_TIME

  constructor: () ->
    bind.call()
    setInterval(( -> logoff_timer()), 1000)

  logoff_timer = () ->

    if document.URL.indexOf('session/new') > -1
      return
    if remaining_seconds <= 1
      window.location = '/session/destroy?jumpto=' + window.location.pathname

      return

    remaining_seconds -= 1
    $('#countdown').html humanize(remaining_seconds)

  # Make seconds human readable.
  humanize = (seconds) ->
    if seconds > 60
      Math.ceil(seconds / 60) + 'm'
    else
      seconds + 's'

  reset_timer = () ->
    remaining_seconds = AUTO_LOGOFF_TIME

  bind = ->
    $(document).ajaxComplete ->
      reset_timer()

    $(document).on 'page:change', ->
      reset_timer()

  new AutoLogoff
