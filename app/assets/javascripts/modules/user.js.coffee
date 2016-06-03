app = window.App ||= {}

class app.User
  constructor: () ->

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


  bind: ->
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

$(document).ready ->
  new app.User().bind()
