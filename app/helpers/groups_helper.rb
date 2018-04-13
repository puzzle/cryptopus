# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module GroupsHelper
  def toggle_api_user(api_user)
    class_name = 'toggle-button'
    class_name += ' toggle-button-selected' if team.teammember?(api_user)

    content_tag(:div, class: class_name, id: api_user.id) do
      content_tag(:button)
    end
  end
end
