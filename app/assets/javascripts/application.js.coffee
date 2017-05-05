# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require clipboard.js
#= require twitter/bootstrap
#= require handlebars.runtime
#= require turbolinks
#= require_tree ./modules
#= require_tree ./templates
#= require password_strength
#= require jquery_strength


# scope for global functions
app = window.App ||= {}

Turbolinks.enableProgressBar()
@flash_messages = []
# Password hidden
# $ ->
#   $( ".select-click" ).on 'click', (e) ->
#     e.target.select()
