# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.TeamMemberHandler
  constructor: () ->
    
  toggle_members: ->
    $('.columns').slideToggle()
    $('.members').slideToggle().promise().done ->
      if $('.columns').is(':visible')
        $('.show_members').text(I18n.teammembers.hide)
        $('html, body').animate { scrollTop:$(document).height() }, 'slow'
      else
        $('.show_members').text(I18n.teammembers.show)
   
   bind: ->
    self = this
    $(document).on 'click', '.show_members', ->
      self.toggle_members()

    $(document).on 'focus', '#search_member', ->
      if $('.members').is(':hidden')
        self.toggle_members()

new app.TeamMemberHandler().bind()
