
# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.AdminTeams
  constructor: () ->
    bind()
  
  show = (td) ->
    ul = $('.members-list', td)
    url = '/api/teams/' + team_id(td.parent()) + '/members'
    $.get(url).done (data) ->
      add_teammembers(data['data']['teammembers'], ul)

  add_teammembers = (members, ul) ->
    members.forEach (member) ->
      li = document.createElement('li')
      li.innerText = member.label
      ul.append(li)

  team_id = (tr) ->
    tr.attr('team-id')

  hide = (td) ->
    ul = $('.members-list', td)
    ul.empty()

  bind = ->
    $(document).on 'click', '.members-link', (e) ->
      e.preventDefault()
      members_link = $(this)
      if members_link.text() == 'Show'
        members_link.text('Hide')
        show(members_link.parent())
      else
        members_link.text('Show')
        hide(members_link.parent())

  new AdminTeams
