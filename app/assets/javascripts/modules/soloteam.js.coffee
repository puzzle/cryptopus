# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Soloteam
  @hideSoloteams: (teams_div) ->
    teams_div.hide()

  @showSoloteams: (teams_div) ->
    teams_div.show()

  @loadTeams: (lastTeammemberTeamsLink, destroyLink) ->
      $.ajax({
        url: lastTeammemberTeamsLink,
        success: (response) =>
          this.onLastTeammemberDataLoaded(response, destroyLink)
      })

  @onLastTeammemberDataLoaded: (response, destroyLink) ->
    if response.data.length == 0 #No last teammember teams for user
      destroyLink.click()
    else
      this.renderTeamsTable(response.data)

  @renderTeamsTable: (teams) ->
    this.showSoloteams()

    new Soloteam
