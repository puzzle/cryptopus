# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.TeamMemberHandler
  constructor: () ->
    
  toggle_members = ->
    $('.members').slideToggle().promise().done ->
      if $('.columns').is(':visible')
        load_members()
        $('.show_members').text(I18n.teammembers.hide)
        $('html, body').animate { scrollTop:$(document).height() }, 'slow'
      else
        $('.show_members').text(I18n.teammembers.show)

  load_members = ->
     team_id = $('input#team_id').val()
     url = '/api/teams/' + team_id + '/members'
     $.get(url).done (data) ->
       render_members(data[1])

  #no_admins_when_private_team(members) = ->
   
  render_members = (members) ->
    members_container = $('.columns')
    content = HandlebarsTemplates['team_member_entry'](members)
    members_container.html(content)

  bind: ->
    $(document).on 'click', '.show_members', ->
      toggle_members()

    #$(document).on 'focus', '#search_member', ->
      #if $('.members').is(':hidden')
        #toggle_members()

new app.TeamMemberHandler().bind()
