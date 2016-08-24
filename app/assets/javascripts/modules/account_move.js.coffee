# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AccountMove
  constructor: () ->
    bind.call()

  load_teams = ->
    team_url = '/api/teams/index'
    $.get(team_url).done (teams) ->
      render_teams(teams['data'])

  render_teams = (teams) ->
    teams_container = $('.move_team')
    if teams_container.length > 0
      content = HandlebarsTemplates['account_edit_dropdown'](teams)
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
    $(document).on 'page:load', load_teams
    $(document).ready(load_teams)
    $(document).on 'change', '.move_team select', (e) ->
      load_groups()

  new AccountMove
