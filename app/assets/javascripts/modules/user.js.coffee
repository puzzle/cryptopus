# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.User
  constructor: () ->
    bind.call()

  hideSoloteams: ->
    @soloteams.hide()

  showSoloteams: ->
    @soloteams.show()

  onDeleteUser: (lastTeammemberTeamsLink, destroyLink) ->
      $.ajax({
        url: lastTeammemberTeamsLink,
        success: (response) =>
          this.onLastTeammemberDataLoaded(response, destroyLink)
      })

  onLastTeammemberDataLoaded: (response, destroyLink) ->
    if response.data.length == 0 #No last teammember teams for user
      destroyLink.click()
    else
      this.renderTeamsTable(response.data)

  renderTeamsTable: (teams) ->
    this.showSoloteams()


  bind = ->
    @team_table = $('#soloteams #team_table')
    @soloteams = $('#soloteams')
    that = this

    $(document).on 'click', '#soloteams_cancel_button', =>
      this.hideSoloteams()


    $(document).on 'click', '#team_table .delete_link', (e) ->
      e.preventDefault()

      element = $(this)

      teammemberLink = $(element).data('last-teammember-teams-link')
      destroyLink = $(element).next()

      that.onDeleteUser(teammemberLink, destroyLink)
      false

    new User
