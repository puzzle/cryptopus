# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe TeammemberSerializer do


  context 'teammember' do

    before(:each) do
      expect_any_instance_of(TeamSerializer)
        .to receive(:user)
        .and_return(users(:admin))
    end

    it 'serializes as not deletable if last teammember' do
      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team2_bob)).to_json)

      expect(as_json['deletable']).to eq(false)
    end

    it 'serializes as deletable if not last teammember and private team' do
      bob = users(:bob)
      bobs_private_key = bob.decrypt_private_key('password')
      plaintext_team_password = teams(:team2).decrypt_team_password(bob, bobs_private_key)
      teams(:team2).add_user(Fabricate(:user), plaintext_team_password)

      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team2_bob)).to_json)

      expect(as_json['deletable']).to eq(true)
    end

    it 'admin is not a admin teammember if private team' do
      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team2_bob)).to_json)

      expect(as_json['admin']).to eq(false)
    end
  end

  context 'normal teammember' do

    before(:each) do
      expect_any_instance_of(TeamSerializer)
        .to receive(:user)
        .and_return(users(:bob))
    end

    it 'serializes as deletable if not last teammember in non_private team' do
      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_bob)).to_json)

      expect(as_json['deletable']).to eq(true)
    end

    it 'serializes as non admin teammember' do
      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_bob)).to_json)

      expect(as_json['admin']).to eq(false)
    end
  end

  context 'admin teammember' do

    before(:each) do
      expect_any_instance_of(TeamSerializer)
        .to receive(:user)
        .and_return(users(:admin))
    end

    it 'serializes as not deletable in non_private team' do
      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_admin)).to_json)

      expect(as_json['deletable']).to eq(false)
    end

    it 'serializes as admin if non_private team' do
      as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_admin)).to_json)

      expect(as_json['admin']).to eq(true)
    end
  end
end
