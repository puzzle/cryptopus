# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AccountMove
  constructor: () ->
    bind.call()

     
  render_teams = ->
    teams_container = $('.move_team')
    team_url = '/api/teams/index'
    team_list = []
    if teams_container.length > 0
      $.get(team_url).done (teams) ->
        content = HandlebarsTemplates['account_edit_dropdown'](teams['data'])
        teams_container.html(content)


  load_groups = ->
    selected = $(".move_list").val()
    url = "/api/teams/#{selected}/groups"
    $.get(url).done (groups) ->
      render_groups(groups['data'])

  render_groups = (groups) ->
    groups_container = $('.move_group')
    content = HandlebarsTemplates['account_edit_dropdown'](groups, 'group_list')
    groups_container.html(content)

  bind = ->
    $(document).on 'page:load', render_teams
    $(document).ready(render_teams)
    $(document).on 'change', '.move_team select', (e) ->
      load_groups()

  new AccountMove
