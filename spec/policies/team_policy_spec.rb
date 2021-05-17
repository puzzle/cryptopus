# frozen_string_literal: true

require 'spec_helper'

describe TeamPolicy do
  include PolicyHelper

  let(:team1) { teams(:team1) }
  let(:team2) { teams(:team2) }
  let(:private_team) { Fabricate(:private_team) }

  context 'everyone' do
    it 'can show his teams' do
      assert_permit alice, Team, :index?
      assert_permit admin, Team, :index?
    end

    it 'can create a new team' do
      assert_permit alice, Team.new, :create?
      assert_permit admin, Team.new, :create?

      assert_permit alice, Team.new, :new?
      assert_permit admin, Team.new, :new?
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

    it 'can add a teammember' do
      assert team2.teammember? bob
      assert_permit bob, team2, :team_member?
    end

    it 'can remove a teammember' do
      expect(team2.teammember?(bob)).to eq true
      assert_permit bob, team2, :team_member?
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

    it 'cannot add a teammember' do
      expect(team2.teammember?(alice)).to eq false
      refute_permit alice, team2, :team_member?
    end

    it 'cannot remove a teammember' do
      expect(team2.teammember?(alice)).to eq false
      refute_permit alice, team2, :team_member?
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
      assert_permit admin, Team, :index_all?
    end

    it 'can list last teammember teams' do
      assert_permit admin, Team, :last_teammember_teams?
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
      assert_permit conf_admin, Team, :index_all?
    end

    it 'can list last teammember teams' do
      assert_permit conf_admin, Team, :last_teammember_teams?
    end

    it 'can list members of all teams' do
      assert_permit conf_admin, private_team, :list_members?
    end
  end

  context 'non-admin' do
    it 'cannot list all teams' do
      refute_permit bob, Team, :index_all?
    end

    it 'cannot list last teammember teams' do
      refute_permit alice, Team, :last_teammember_teams?
    end

    it 'cannot list members of team he isnt member of' do
      refute_permit alice, team2, :last_teammember_teams?
    end
  end
end
