#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Finders::GroupsFinder < Finders::BaseFinder
  def find(user, term)
    groups(user).where('name like ?', "%#{term}%")
  end

  private

  def groups(user)
    Group.joins('INNER JOIN teammembers ON groups.team_id = teammembers.team_id').
      where(teammembers: { user_id: user.id })
  end
end
