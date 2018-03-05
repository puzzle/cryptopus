#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Finders::TeamsFinder < Finders::BaseFinder
  def find(user, term)
    user.teams.where('name like ?', "%#{term}%")
  end
end
