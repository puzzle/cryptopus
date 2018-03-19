# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.TeamMembers
  constructor: () ->
    bind.call()

  toggle_members = ->
    if $('.columns').is(':visible')
      $('.members').hide().promise()
      $('.show_members').text(I18n.teammembers.show)
    else
      show_members()


  show_members = ->
    $('.members').show().promise()
    load_members()
    $('.show_members').text(I18n.teammembers.hide)


  load_candidates = ->
    input_field = $('#search_member')
    term = input_field.val()
    team_id = $('input#team_id').val()
    url = '/api/teams/' + team_id + '/members/candidates'
    $.get(url).done (data) ->
      render_candidates(data['data']['users'])

  render_candidates = (users) ->
    availableUsers = []
    users.forEach (user) ->
      availableUsers.push({label: user['label'], data:{id: user['id']}})
    $('input#search_member').autocomplete
      source: availableUsers
      select: (event, ui) ->
        add_member(ui)

  add_member = (ui)->
    create_member(ui).complete ->
      $('input#search_member').val('')
      app.flash.add('user added')
      load_members()
      load_candidates()

  create_member = (ui)->
    id = ui.item.data.id
    team_id = $('input#team_id').val()
    url = '/api/teams/' + team_id + '/members'
    $.post(url, user_id: id)

  load_members = ->
    team_id = $('input#team_id').val()
    url = '/api/teams/' + team_id + '/members'
    $.get(url).done (data) ->
      render_members(data['data']['teammembers'])

  delete_member = (e) ->
    parent_li = $(e.target).parents('li')
    user_id = parent_li.data().value.user_id
    team_id = $('input#team_id').val()

    url = '/api/teams/' + team_id + '/members/' + user_id
    $.ajax({
      url: url,
      type: 'DELETE',
      complete: ->
        load_members()
        load_candidates()
        app.flash.add('user removed')
    })

  render_members = (members) ->
    members_container = $('.columns')
    content = HandlebarsTemplates['team_member_entry'](members)
    members_container.html(content)

  bind = ->
    $(document).on 'click', '#search_member', (e) ->
      show_members()
      load_candidates()

    $(document).on 'click', '.show_members', (e) ->
      e.preventDefault()
      toggle_members()
      load_members()

    $(document).on 'click', '.members li .remove_member', (e) ->
      e.preventDefault()
      delete_member(e)

    $(document).on 'click', '#members-tab', ->
      toggle_members()
      load_members()

  new TeamMembers
