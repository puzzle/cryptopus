# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe Team do

  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }

  it 'removes all assoziated folders, encryptables, teammembers if team is destroyed' do
    team1 = teams(:team1)
    credentials1 = encryptables(:credentials1)
    folder1 = folders(:folder1)

    team1.destroy

    expect(team1).to be_destroyed
    expect do
      Folder.find(folder1.id)
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect do
      Encryptable.find(credentials1.id)
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(Teammember.where(team_id: team1.id)).to be_empty
  end

  it 'returns teammember candidates' do
    teammembers(:team1_bob).destroy

    team = teams(:team1)
    candidates = team.member_candidates

    expect(candidates).to_not include(users(:root))
    expect(candidates).to_not include(users(:alice))
    expect(candidates).to_not include(users(:admin))
    expect(candidates).to include(users(:bob))
  end

  it 'never includes root in member candidates' do
    team = Fabricate(:private_team)

    candidates = team.member_candidates

    expect(candidates).to_not include(users(:root))
    expect(candidates).to include(users(:alice))
    expect(candidates).to include(users(:admin))
    expect(candidates).to include(users(:bob))
  end

  it 'does not add user if already teammember' do
    team = teams(:team1)
    plaintext_private_key = decrypt_private_key(alice)
    plaintext_team_pw = team.decrypt_team_password(alice, plaintext_private_key)

    expect do
      team.add_user(bob, plaintext_team_pw)
    end.to raise_error(/user is already team member/)
  end

  it 'adds user to team' do
    team = teams(:team1)
    plaintext_team_password = team.
                              decrypt_team_password(bob, decrypt_private_key(bob))

    team.remove_user(alice)

    expect do
      team.add_user(alice, plaintext_team_password)
    end.to change { team.teammembers.count }.by(1)

    alice_plaintext_team_password = team.
                                    decrypt_team_password(alice, decrypt_private_key(alice))

    expect(alice_plaintext_team_password).to eq(plaintext_team_password)
  end

  it 'removes user from team' do
    team = teams(:team1)

    expect do
      team.remove_user(alice)
    end.to change { team.teammembers.count }.by(-1)
  end

  it 'creates new team adds creator and admins' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = false

    team = Team.create(bob, params)

    expect(team.teammembers.count).to eq(3)
    user_ids = team.teammembers.pluck(:user_id)
    expect(user_ids).to include(bob.id)
    expect(user_ids).to include(users(:admin).id)
    expect(team).to_not be_private
    expect(team.name).to eq('foo')
    expect(team.description).to eq('foo foo')
  end

  it 'creates new team adds creator' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = true

    team = Team.create(bob, params)

    expect(team.teammembers.count).to eq(1)
    user_ids = team.teammembers.pluck(:user_id)
    expect(user_ids).to include(bob.id)
    expect(team).to be_private
    expect(team.name).to eq('foo')
    expect(team.description).to eq('foo foo')
  end

  it 'creates new team adds creator only' do
    params = {
      name: 'foo',
      description: 'foo foo',
      private: true
    }

    team = Team.create(bob, params)

    expect(team.teammembers.count).to eq(1)
    user_ids = team.teammembers.pluck(:user_id)
    expect(user_ids).to include(bob.id)
    expect(team).to be_private
    expect(team.name).to eq('foo')
    expect(team.description).to eq('foo foo')
  end

  it 'does not create team if name is empty' do
    params = {
      name: '',
      description: 'foo foo',
      private: false
    }

    team = Team.create(bob, params)

    expect(team).to_not be_valid
    expect(team.errors.full_messages.first).to match(/Name/)
  end

  it 'creates team with invalid team name' do
    params = {
      name: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr',
      description: 'foo foo',
      private: false
    }

    team = Team.create(bob, params)
    expect(team.valid?).to eq(false)
  end
end
