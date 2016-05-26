app = window.App ||= {}

class app.User
  constructor: () ->

  hideSoloteams = ->
    $('#soloteams').hide()


  bind: ->
    $(document).on 'click', '#soloteams-cancel', ->
      hideSoloteams()

new app.User().bind()
