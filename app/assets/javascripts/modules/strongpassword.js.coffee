# Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

app = window.App ||= {}

class app.Strongpassword
  constructor: () ->
    bind.call()

  showStrength = ->
    $.strength.weakImage = "/assets/weak.png"
    $.strength.goodImage = "/assets/good.png"
    $.strength.strongImage = "/assets/strong.png"
    $.strength("#account_cleartext_username", "#account_cleartext_password")

  bind = ->
    $(document).on 'page:change', showStrength

  new Strongpassword
