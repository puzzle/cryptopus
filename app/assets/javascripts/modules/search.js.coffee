# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Search
  self = undefined
  constructor: () ->
    self = this
    bind.call()

  ready = ->
    new Clipboard('.clip_button')

  searchTeams = (term) ->
    return $.get('/api/search/teams', q: term).then (data) ->
      teams = data.data.teams
      HandlebarsTemplates['search/team_result_entry'](teams)

  searchGroups = (term) ->
    return $.get('/api/search/groups', q: term).then (data) ->
      groups = data.data.groups
      HandlebarsTemplates['search/group_result_entry'](groups)

  searchAccounts = (term) ->
    return $.get('/api/search/accounts', q: term).then (data) ->
      accounts = data.data.accounts
      HandlebarsTemplates['search/account_result_entry'](accounts)

  updateResultArea = (content) ->
    $('.result-list').html(content)

  doSearch = ->
    input_field = $('.search-input')
    $('.result-info').hide()
    term = input_field.val()
    if input_field.val().length <= 2
      updateResultArea('')
    else
      $.when(searchAccounts(term), searchGroups(term), searchTeams(term)).then (accounts, groups, teams) ->
          content = accounts + groups + teams
          updateResultArea(content)
          debugger
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

  bind = ->
    $(document).on 'page:load', ready
    $(document).ready(ready)

    $(document).on 'keyup', '.search-input', ->
      doSearch()

    $(document).on 'click', '.password-show', (e) ->
      showPassword(e)

    $(document).on 'click', '.clip_button', (e) ->
      app.AccountHelper.showCopyMessage(e, '.clip_button')

  new Search
