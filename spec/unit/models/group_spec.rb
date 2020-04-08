# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe Group do

  it 'does not create second group in same team' do
    params = { name: 'group1', team_id: teams(:team1).id }

    group = Group.new(params)

    expect(group).to_not be_valid
    expect(group.errors.keys).to eq([:name])
  end

  it 'creates second group' do
    params = { name: 'group1', team_id: teams(:team2).id }
    group = Group.new(params)

    expect(group).to be_valid
  end

  it 'does not create group if name is empty' do
    params = { name: '', description: 'foo foo' }
    group = Group.new(params)

    expect(group).to_not be_valid
    expect(group.errors.full_messages.first).to match(/Name/)
  end
end
