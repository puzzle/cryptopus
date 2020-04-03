# Copyright (c) 2008-2017, Puzzle ITC GmbH.
# This file is part of Cryptopus and licensed
# under the Affero General Public License
# version 3 or later. See the COPYING file
# at the top-level directory or at
# https://github.com/puzzle/cryptopus.

Handlebars.registerHelper 'I18n', (str) ->
  if I18n !=undefined then I18n.t(str) else str


Handlebars.registerHelper 'ApiUserTimeText', (time) ->
  Handlebars.helpers.I18n(timeToString(time))

timeToString = (time) ->
  switch(time)
    when 0 then 'profile.api_users.options.infinite'
    when 60 then 'profile.api_users.options.one_min'
    when 300 then 'profile.api_users.options.five_mins'
    when 43200 then 'profile.api_users.options.twelve_hours'
