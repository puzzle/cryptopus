# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe Folder do

  it 'does not create second folder in same team' do
    params = { name: 'folder1', team_id: teams(:team1).id }

    folder = Folder.new(params)

    expect(folder).to_not be_valid
    expect(folder.errors.keys).to eq([:name])
  end

  it 'creates second folder' do
    params = { name: 'folder1', team_id: teams(:team2).id }
    folder = Folder.new(params)

    expect(folder).to be_valid
  end

  it 'does not create folder if name is empty' do
    params = { name: '', description: 'foo foo' }
    folder = Folder.new(params)

    expect(folder).to_not be_valid
    expect(folder.errors.full_messages.first).to match(/Name/)
  end
end
