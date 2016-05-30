app = window.App ||= {}

class app.User
  constructor: () ->

  hideSoloteams = ->
    $('#soloteams').hide()


  bind: ->
    $(document).on 'click', '#soloteams_cancel_button', ->
      hideSoloteams()

new app.User().bind()
