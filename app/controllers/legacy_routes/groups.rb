# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class LegacyRoutes::Groups

  GROUPS_STRING = 'accounts'

  def redirect_url(url)
    last_element = url.downcase.split('/').last
    if last_element == GROUPS_STRING
      url.downcase.remove(last_element)
    else
      url
    end
  end
end
