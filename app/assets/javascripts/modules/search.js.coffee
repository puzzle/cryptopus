#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Search

  constructor: () ->

  ready = ->
    new Clipboard('.clip_button_search')

  updateResultArea = (data) ->
    content = HandlebarsTemplates['search/result_entry'](data)
    $('.result-list').html(content)

  doSearch = ->
    input_field = $('.search-input')
    $('.result-info').hide()
    term = input_field.val()
    if input_field.val().length > 2
      updateResultArea ''
      $.get('/search/account.json', search_string: term).done (data) ->
        if data.accounts.length > 0
          updateResultArea(data.accounts)
        else
          $('.result-info').show()

  registerActions = (e) ->
    e.preventDefault()
    result_password = $(e.target).next('.result-password')
    result_password.css 'top', '0px'
    result_password.css 'padding-bottom', '48px'
    passLink = $(e.target)
    passInput = passLink.next('.password-hidden')
    passLink.hide()
    passInput.removeClass('hide')
    timeOut(passInput, result_password, passLink)


  showMessage = (e) ->
    $(e.target).next('.copied').fadeIn('fast')
    setTimeout (->
      $(e.target).next('.copied').fadeOut('fast')
      return
    ), 2000

  timeOut = (passInput, result_password, passLink)->
    setTimeout (->
      passInput.select()
      return
    ), 80

    setTimeout (->
      result_password.css 'top', '-48px'
      result_password.css 'padding-bottom', '0px'
      passLink.show()
      passInput.addClass 'hide'
      return
    ), 5000


  bind: ->
    $(document).on 'page:load', ready
    $(document).ready(ready)

    $(document).on 'keyup', '.search-input', ->
      doSearch()

    $(document).on 'click', '.password-show', (e)->
      registerActions(e)
    $(document).on 'click', '.clip_button_search', (e) ->
      showMessage(e)


new app.Search().bind()
