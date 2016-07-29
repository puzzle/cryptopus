# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.User
  constructor: () ->
    bind.call()

  hideLastTeammemberTeams = ->
    $(@last_teammember_teams).hide()

  showLastTeammemberTeams = ->
    $(@last_teammember_teams).show()

  onDeleteUser = (lastTeammemberTeamsLink, username) ->
      $.ajax({
        url: lastTeammemberTeamsLink,
        success: (response) =>
          onLastTeammemberDataLoaded(response, username)
      })

  onLastTeammemberDataLoaded = (response, username) ->
    showLastTeammemberTeams()
    teams = response.data
    console.log teams.length
    if teams.teams.length == 0 #No last teammember teams for user
      showWarningMessage(username)
    else
      renderLastTeammemberTeams(teams)

  renderLastTeammemberTeams = (teams) ->
    template = HandlebarsTemplates['last_teammember_teams']
    compiled_html = template(teams)
    $('#last_teammember_teams_table').html(compiled_html)

  showWarningMessage = (username) ->
    debugger
    $('#delete_user_button').prop('disabled', false)

  deleteLastTeammemberTeam = (team_id) ->
    url = '/api/teams/' + team_id
    $.ajax({
      url: url,
      type: 'DELETE'
    })

  bind = ->
    @last_teammember_teams = '#last_teammember_teams'

    $(document).on 'click', '#last_teammember_teams_cancel_button', =>
      hideLastTeammemberTeams()


    $(document).on 'click', '#team_table .delete_user_link', (e) ->
      element = $(this)
      teammemberLink = element.data('last-teammember-teams-link')
      username = element.data('username')
      onDeleteUser(teammemberLink, username)

   $(document).on 'click', '#delete_last_teammember_team_link', (e) ->
      team_id_element = $(this).closest('tr').find('#last_teammember_team_id')
      team_id = parseInt(team_id_element.text())
      debugger
      deleteLastTeammemberTeam(team_id)


  new User
