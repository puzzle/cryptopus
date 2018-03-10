#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Finders::AccountsFinder < Finders::BaseFinder
  def apply
    @term.split(' ').inject(@records.includes(group: [:team])) do |relation, term|
      relation.where('accountname like ? or accounts.description like ?', "%#{term}%", "%#{term}%")
    end
  end
end
