# Copyright (c) 2008-2017, Puzzle ITC GmbH.
# This file is part of Cryptopus and licensed
# under the Affero General Public License
# version 3 or later. See the COPYING file
# at the top-level directory or at
# https://github.com/puzzle/cryptopus.
#
#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require jquery.turbolinks
#= require clipboard.js
#= require twitter/bootstrap
#= require handlebars.runtime
#= require selectize
#= require_tree ./modules
#= require_tree ./templates
#= require password_strength
#= require jquery_strength
#= require i18n.js
#= require i18n/translations
#= require localization
#= require turbolinks
#= require turbolinks-compatibility
#= require handlebars_helpers

# scope for global functions
app = window.App ||= {}

@flash_messages = []

I18n.fallbacks = true
