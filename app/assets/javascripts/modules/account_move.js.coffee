# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AccountMove
  constructor: () ->
    bind.call()

  load_teams = ->
    url = '/api/teams/index'
    $.get(url).done (data) ->
      render_teams(data['data'])

  render_teams = (teams) ->
    teams_container = $('.move_team')
    content = HandlebarsTemplates['account_edit_dropdown'](teams)
    teams_container.html(content)


  load_groups = ->
    url = '/api/teams/groups/index'
    $.get(url).done (data) ->
      render_groups(data['data'])

  render_groups = (teams) ->
    groups_container = $('.move_team')
    content = HandlebarsTemplates['account_edit_dropdown'](groups)
    groups_container.html(content)

  bind = ->
    $(document).on 'page:load', load_teams()

  new AccountMove
