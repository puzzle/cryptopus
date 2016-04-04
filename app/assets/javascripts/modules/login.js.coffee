app = window.App ||= {}

class app.LoginHandler
  constructor: () ->

  setFocus = ->

    password_input = $('#password')
    user_input = $('#username')
    stored_username = localStorage.getItem('username')
    input_username = user_input.val()

    if stored_username != null and stored_username != ''
      user_input.val stored_username
      password_input.val ''
      password_input.focus()
    else
      user_input.focus()

  selectUsername = ->
    $('#username').select()
    return

  setLocalUsername = ->
    localStorage.setItem 'username', $('#username').val()
    return

  bind: ->
    $(document).on 'page:change', ->
      setFocus()

    $(document).on 'submit', '.login', ->
      setLocalUsername()

    $(document).on 'click', '#username', ->
      selectUsername()

new app.LoginHandler().bind()
