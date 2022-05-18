# frozen_string_literal: true

require 'spec_helper'

describe TeamPolicy do
  include PolicyHelper

  let(:team1) { teams(:team1) }
  let(:team2) { teams(:team2) }
  let(:private_team) { Fabricate(:private_team) }
  let(:personal_team_bob) { teams(:personal_team_bob) }

  context 'everyone' do
    it 'can show his teams' do
      assert_permit alice, Team::Shared, :index?
      assert_permit admin, Team::Shared, :index?
    end

    it 'can create a new team' do
      assert_permit alice, Team::Shared.new, :create?
      assert_permit admin, Team::Shared.new, :create?

      assert_permit alice, Team::Shared.new, :new?
      assert_permit admin, Team::Shared.new, :new?
    end
  end

  context 'as teammember' do
    it 'can edit a team' do
      assert team2.teammember? bob
      assert_permit bob, team2, :edit?
    end

    it 'cannot delete a team' do
      expect(team2.teammember?(bob)).to eq true
      refute_permit bob, team2, :destroy?
    end
  end

  context 'non-teammember' do
    it 'cannot edit a team' do
      expect(team2.teammember?(alice)).to eq false
      refute_permit alice, team2, :edit?
    end

    it 'cannot delete a team' do
      expect(team2.teammember?(alice)).to eq false
      refute_permit alice, team2, :destroy?
    end

  end

  context 'as admin' do
    it 'can edit a public team' do
      expect(team1).to_not be_private
      assert_permit admin, team1, :edit?
    end

    it 'cannot edit a private team' do
      expect(private_team).to be_private
      refute_permit admin, private_team, :edit?
    end

    it 'can delete any team' do
      assert_permit admin, team1, :destroy?
      assert_permit admin, team2, :destroy?
      assert_permit admin, private_team, :destroy?
    end

    it 'can list all teams' do
      assert_permit admin, Team::Shared, :index_all?
    end

    it 'can list last teammember teams' do
      assert_permit admin, Team::Shared, :only_teammember?
    end

    it 'can list members of all teams' do
      assert_permit admin, private_team, :list_members?
    end
  end

  context 'conf admin' do
    it 'can delete a team with only one teammember' do
      assert_permit conf_admin, team2, :destroy?
    end

    it 'cannot delete a team with more than one teammmember' do
      refute_permit conf_admin, team1, :destroy?
    end

    it 'can list all teams' do
      assert_permit conf_admin, Team::Shared, :index_all?
    end

    it 'can list last teammember teams' do
      assert_permit conf_admin, Team::Shared, :only_teammember?
    end

    it 'can list members of all teams' do
      assert_permit conf_admin, private_team, :list_members?
    end
  end

  context 'non-admin' do
    it 'cannot list all teams' do
      refute_permit bob, Team::Shared, :index_all?
    end

    it 'cannot list last teammember teams' do
      refute_permit alice, Team::Shared, :only_teammember?
    end

    it 'cannot list members of team he isnt member of' do
      refute_permit alice, team2, :only_teammember?
    end
  end
  context 'personal team' do
    it 'cannot edit personal_team' do
      expect(personal_team_bob.teammember?(bob)).to eq(true)
      refute_permit bob, personal_team_bob, :update?
    end

    it 'cannot delete personal_team' do
      expect(personal_team_bob.teammember?(bob)).to eq(true)
      refute_permit bob, personal_team_bob, :destroy?
    end
  end
end
