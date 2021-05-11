# frozen_string_literal: true

#  Copyright (c) 2008-2018, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe Team::ApiUser do
  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:team) { teams(:team1) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }

  context '#list' do
    it 'lists api_users of user' do
      create_api_user
      create_api_user
      alice.api_users.create
      api_users = Team::ApiUser.list(bob, team)

      expect(api_users.count).to eq(2)
    end
  end

  context '#enable' do
    it 'enables api user for team' do
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      team_api_user = Team::ApiUser.new(create_api_user, team)
      team_api_user.enable(plaintext_team_password)

      expect(team_api_user).to be_enabled
    end
  end

  context '#disable' do
    it 'disables api user for team ' do
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      team_api_user = Team::ApiUser.new(create_api_user, team)
      team_api_user.enable(plaintext_team_password)
      team_api_user.disable

      expect(team_api_user).to_not be_enabled
    end
  end

  private

  def create_api_user
    bob.api_users.create
  end
end
