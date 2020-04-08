# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Finders::GroupsFinder do

  context 'as teammember' do
    it 'finds his groups' do
      groups = find(Group.all, 'group1')
      expect(groups.count).to eq(1)
      expect(groups.first.name).to eq('group1')
    end

    it 'does not find a group with invalid query' do
      groups = find(Group.all, '42group42')
      expect(groups.count).to eq(0)
    end
  end

  private

  def find(groups, query)
    Finders::GroupsFinder.new(groups, query).apply
  end
end
