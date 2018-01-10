# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.User
  self = undefined
  constructor: () ->
    self = this
    bind.call()

  hideLastTeammemberTeams = ->
    $(@last_teammember_teams).hide()
    $('.alert-info.last-teammembers').hide()
    $('.alert-danger.delete-user').hide()

  showLastTeammemberTeams = ->
    $(@last_teammember_teams).show()

  onDeleteUser = (lastTeammemberTeamsLink) ->
    $.ajax({
      url: lastTeammemberTeamsLink,
      success: (response) ->
        onLastTeammemberDataLoaded(response)
    })

  onLastTeammemberDataLoaded = (response) ->
    showLastTeammemberTeams()
    teams = response.data.teams
    if teams.length == 0 #No last teammember teams for user
      showWarningMessage()
    else
      renderLastTeammemberTeams(teams)

  renderLastTeammemberTeams = (teams) ->
    template = HandlebarsTemplates['last_teammember_teams']
    compiled_html = template(teams)
    $('#last_teammember_teams_table').html(compiled_html)
    $('.alert-info.last-teammembers').show()
    $('#delete_user_button').prop('disabled', true)

  showWarningMessage = () ->
    $('#delete_user_button').prop('disabled', false)
    $('.alert-danger.delete-user').show()
    $('.alert-info.last-teammembers').hide()
    $('#last_teammember_teams_table').html('')

  deleteLastTeammemberTeam = (team_id) ->
    url = '/api/teams/' + team_id
    $.ajax({
      url: url,
      type: 'DELETE',
      success: ->
        onDeleteUser(self.teammemberLink)
    })

  deleteUser = () ->
    url = '/api/admin/users/' + self.user_id
    $.ajax({
      url: url,
      type: 'DELETE'
      success: ->
        userIdAttribute = '[data-user-id=' + self.user_id + ']'
        $(userIdAttribute).parents('tr').remove()
      complete: ->
        hideLastTeammemberTeams()
    })

  bind = ->
    @last_teammember_teams = '#last_teammember_teams'

    $(document).on 'click', '#last_teammember_teams_cancel_button', ->
      hideLastTeammemberTeams()


    $(document).on 'click', '#team_table .delete_user_link', (e) ->
      e.preventDefault()
      element = $(this)
      self.teammemberLink = element.data('last-teammember-teams-link')
      self.user_id = element.data('user-id')
      onDeleteUser(self.teammemberLink)

   $(document).on 'click', '#delete_last_teammember_team_link', (e) ->
     team_id_element = $(this).closest('tr').find('#last_teammember_team_id')
     team_id = parseInt(team_id_element.text())
     deleteLastTeammemberTeam(team_id)

   $(document).on 'click', '#delete_user_button', ->
     deleteUser()

  new User
