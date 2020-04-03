# Copyright (c) 2008-2017, Puzzle ITC GmbH.
# This file is part of Cryptopus and licensed under
# the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.TestLdapConnection
  constructor: () ->
    bind.call()

  test_ldap_connection = (url) ->
    $.ajax({
      type: "GET",
      url: url,
    })

  bind = ->
    $(document).on 'click', '#ldap-button', ->
      url = '/api/admin/ldap_connection_test/new'
      test_ldap_connection(url)

  new TestLdapConnection
