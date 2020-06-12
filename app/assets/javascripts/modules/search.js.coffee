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
    doSearch.call()

  search = (term, search_type) ->
    search_end_point = search_type
    if search_end_point == "folders"
      search_end_point = "all_folders"
    return $.get('/api/'+search_end_point, q: term).then (data) ->

      objects = deserializeJSON(data)
      HandlebarsTemplates['search/'+search_type+'_result_entries'](objects)

  updateResultArea = (content, search_type) ->
    $('.result-list.'+search_type).html(content)

  doSearch = ->
    search_type = $('li.tab.active').attr('id')
    input_field = $('.search-input')
    return unless input_field.length
    $('.result-info').hide()
    term = input_field.val()
    history.replaceState({}, '', '?q=' + term)
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

      data.data.attributes.folder_name = data.included[0].attributes.name
      data.data.attributes.team_id = data.included[0].attributes.team_id
      data.data.attributes.team_name = data.included[0].attributes.team_name

      content = HandlebarsTemplates['search/account_full'](data.data)
      div.html(content)
      div.find('.result-description')[0].style.pointerEvents = 'auto'

  deserializeJSON = (data) ->
    for d in data.data
      if d.type != 'folders'
        if d.relationships.folders
          relationship_folder_ids = d.relationships.folders.data.map (folder) -> folder.id
        else
          relationship_folder_ids = [d.relationships.folder.data.id]
        if data.included
          folder = data.included.find (element) -> relationship_folder_ids.includes(element.id)
      else
        folder = d

      if folder
        d.attributes.folder_name = folder.attributes.name
        d.attributes.team_name = folder.attributes.team_name
        d.attributes.team_id = folder.attributes.team_id

    return data.data


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
