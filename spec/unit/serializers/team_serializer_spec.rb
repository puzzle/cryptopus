# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe TeamSerializer do

  context 'normal user' do

    before do
      allow_any_instance_of(TeamSerializer)
        .to receive(:current_user)
        .and_return(users(:bob))
    end

    it 'serializes not as deletable if user' do
      as_json = JSON.parse(TeamSerializer.new(teams(:team1)).to_json)

      expect(as_json['deletable']).to eq(false)
    end
  end

  context 'admin' do

    before do
      allow_any_instance_of(TeamSerializer)
        .to receive(:current_user)
        .and_return(users(:admin))
    end

    it 'serializes as deletable if admin' do
      as_json = JSON.parse(TeamSerializer.new(teams(:team1)).to_json)

      expect(as_json['deletable']).to eq(true)
    end

  end

  context 'conf-admin' do

    before do
      allow_any_instance_of(TeamSerializer)
        .to receive(:current_user)
        .and_return(users(:conf_admin))
    end

    it 'serializes as deletable if conf-admin and team size is 1' do
      as_json = JSON.parse(TeamSerializer.new(teams(:team2)).to_json)

      expect(as_json['deletable']).to eq(true)
    end

    it 'serializes not as deletable if conf-admin but team size larger than 1' do
      as_json = JSON.parse(TeamSerializer.new(teams(:team1)).to_json)

      expect(as_json['deletable']).to eq(false)
    end
  end

end
