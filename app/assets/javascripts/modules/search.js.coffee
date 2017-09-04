# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Search
  constructor: () ->
    bind.call()

  ready = ->
    new Clipboard('.clip_button')

  search = (term, search_type) ->
    return $.get('/api/search/'+search_type, q: term).then (data) ->
      objects = data.data[search_type]
      HandlebarsTemplates['search/'+search_type+'_result_entries'](objects)

  updateResultArea = (content, search_type) ->
    $('.result-list.'+search_type).html(content)

  doSearch = ->
    search_type = $('li.tab.active').attr('id')
    input_field = $('.search-input')
    $('.result-info').hide()
    term = input_field.val()
    if input_field.val().length <= 2
      updateResultArea('', search_type)
    else
      $.when(search(term, search_type)).then (content) ->
          updateResultArea(content, search_type)
          $('.result-info').show() if content.replace(/\s/g, '') == ''

  showPassword = (e) ->
    e.preventDefault()
    result_password = $(e.target).next('.result-password')
    result_password.css 'top', '0px'
    result_password.css 'padding-bottom', '48px'
    passLink = $(e.target)
    passInput = passLink.next('.password-hidden')
    passLink.hide()
    passInput.removeClass('hide')
    timeOut(passInput, result_password, passLink)

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

  foldOutAccount = (e) ->
    li = $(e.target)
    div = $(e.target).parent()
    $.get(li.data('account-path')).then (data) ->
      account = data.data['account']
      content = HandlebarsTemplates['search/account_full'](account)
      div.html(content)
      div.find('.result-description')[0].style.pointerEvents = 'auto'

  bind = ->
    $(document).on 'page:load', ready
    $(document).ready(ready)

    $(document).on 'click', '.account-entry', (e) ->
      foldOutAccount(e)

    $(document).on 'click', 'li.tab', ->
      doSearch()

    $(document).on 'keyup', '.search-input', ->
      doSearch()

    $(document).on 'click', '.password-show', (e) ->
      showPassword(e)

    $(document).on 'click', '.clip_button', (e) ->
      app.AccountHelper.showCopyMessage(e, '.clip_button')

  new Search
