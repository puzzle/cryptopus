#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Search

  constructor: () ->
    bind.call()

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


#  showMessage = (e) ->
#    if $(e.target).hasClass('btn clip_button_search')
#      $(e.target).next('.copied').fadeIn('fast')
#      setTimeout (->
#        $(e.target).next('.copied').fadeOut('fast')
#        return
#      ), 2000
#    else
#      par = $(e.target).parent()
#      showMessage(par)

  showMessage = (e) ->
    button = e.target.closest('.clip_button_search')
    par = $(button).parent()
    if $(par).hasClass('result-password select-click')
        message = '<p class="copied" >Password copied! </p>'
        div = '.result-password'
    else
        message = '<p class="copied" >Username copied! </p>'
        div = '.result-username'
    $(message).appendTo div
    par.find($('.copied')).fadeIn('fast')
    setTimeout (->
      $(div).find($('.copied')).remove()
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


  bind = ->
    $(document).on 'page:load', ready
    $(document).ready(ready)

    $(document).on 'keyup', '.search-input', ->
      doSearch()

    $(document).on 'click', '.password-show', (e) ->
      registerActions(e)

    $(document).on 'click', '.clip_button_search', (e) ->
      showMessage(e)

  new Search
