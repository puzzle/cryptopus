# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.SettingSelectize
  constructor: () ->
    bind.call()

  selectize_countries = ->
    return if $("#country-whitelist").length <= 0
    $("#country-whitelist").selectize(
      addPrecedence: true
      allowEmptyOption: true
      plugins: ['remove_button']
      items: $("#country-whitelist").data('whitelist').split(' ')
      sortField:
        field: 'text'
        direction: 'asc'
    )

  selectize_ips = ->
    return if $("#ip-whitelist").length <= 0
    $("#ip-whitelist").selectize(
      create: true
      addPrecedence: true
      allowEmptyOption: true
      plugins: ['remove_button']
      items: $("#ip-whitelist").data('whitelist').split(' ')
    )

  selectize_hosts = ->
    return if $("#host-whitelist").length <= 0
    $("#host-whitelist").selectize(
      delimiter: ','
      create: true
      addPrecedence: true
      allowEmptyOption: true
      plugins: ['remove_button']
      items: $("#host-whitelist").data('whitelist').split(' ')
    )

  bind = ->
    $(document).on 'page:change', selectize_countries
    $(document).on 'page:change', selectize_ips
    $(document).on 'page:change', selectize_hosts

  new SettingSelectize
