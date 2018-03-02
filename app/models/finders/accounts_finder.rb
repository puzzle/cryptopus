#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Finders::AccountsFinder < Finders::BaseFinder
  def find(user, query)
    query.split(' ').inject(accounts(user).includes(group: [:team])) do |relation, term|
      relation.where('accountname like ? or accounts.description like ?', "%#{term}%", "%#{term}%")
    end
  end
  
  def find_by_tag(user, tag)
    tag.split(' ').inject(accounts(user).includes(group: [:team])) do |relation, term|
      relation.where('tag like ?', "%#{term}%")
    end
  end

  private

  def accounts(user)
    Account.joins(:group).
      joins('INNER JOIN teammembers ON groups.team_id = teammembers.team_id').
      where(teammembers: { user_id: user.id })
  end
end
