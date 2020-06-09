# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

# scope for global functions
app = window.App ||= {}

class app.Folders

  render_folders = (teams) ->
    template = HandlebarsTemplates['folders']

    compiled_html = template()
    $('.message_container').html(compiled_html)
