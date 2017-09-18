# Copyright (c) 2008-2016, Puzzle ITC GmbH.
# This file is part of Cryptopus and licensed
# under the Affero General Public License
# version 3 or later. See the COPYING file
# at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.AccountMove
  constructor: () ->
    bind.call()

  renderMoveAccountForm = ->
    $(@account_move).show()
    render_teams()
     
  render_teams = ->
    teams_container = $('.move_list_team')
    team_url = '/api/teams'
    team_list = []
    team_value = $(".team_value").val()
    if teams_container.length > 0
      $.get(team_url).done (teams) ->
        content = HandlebarsTemplates['account_edit_dropdown'](teams.data.teams)
        teams_container.html(content)
        $('.move_list_team option[value=' + team_value + ']').prop 'selected', 'selected'
        load_groups()

  load_groups = ->
    selected = $(".move_list_team").val()
    url = "/api/teams/#{selected}/groups"
    $.get(url).done (groups) ->
      render_groups(groups.data.groups)

  render_groups = (groups) ->
    groups_container = $('.move_list_group')
    group_value = $(".group_value").val()
    content = HandlebarsTemplates['account_edit_dropdown'](groups)
    groups_container.html(content)
    $('.move_list_group option[value=' + group_value + ']').prop 'selected', 'selected'


  bind = ->
    @account_move = '#move_account_form'
    $(document).on 'page:load', render_teams
    $(document).on 'change', '.move_team select', (e) ->
      load_groups()
    $(document).on 'click', '#move_account_button', (e) ->
      e.preventDefault()
      renderMoveAccountForm()

  new AccountMove
