# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Finders::TeamsFinder do

  context 'as teammember' do
    it 'finds his teams' do
      teams = find(Team.all, 'team1')
      expect(teams.first.name).to eq('team1')
    end

    it 'does not find a team with invalid query' do
      teams = find(Team.all, '42team42')
      expect(teams.count).to eq(0)
    end
  end

  private

  def find(teams, query)
    Finders::TeamsFinder.new(teams, query).apply
  end
end
