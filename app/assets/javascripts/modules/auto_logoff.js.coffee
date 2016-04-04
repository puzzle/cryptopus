app = window.App ||= {}

class app.Auto_logoffHandler
  constructor: () ->

  AUTO_LOGOFF_TIME = 300
  remaining_seconds = AUTO_LOGOFF_TIME

  auto_logoff = ->
    if document.URL.indexOf('/login/login') > -1
      return
    if remaining_seconds <= 1
      window.location = '/login/logout'
      return
    remaining_seconds -= 1
    $('#countdown').html humanize(remaining_seconds)
    setTimeout 'auto_logoff()', 1000
    return

  # Make seconds human readable.

  humanize = (seconds) ->
    if seconds > 60
      Math.ceil(seconds / 60) + 'm'
    else
      seconds + 's'

  bind: ->
    $('.login').submit ->
      auto_logoff()
      return

    $(document).on 'page:load', ->
      remaining_seconds = AUTO_LOGOFF_TIME
      return


new app.Auto_logoffHandler().bind()
