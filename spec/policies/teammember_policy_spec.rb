# frozen_string_literal: true

require 'spec_helper'

describe TeammemberPolicy do
  include PolicyHelper

  let(:team2) { teams(:team2) }
  let(:personal_team_bob) { teams(:personal_team_bob) }

  context 'create' do
    it 'can add additional teammember as teammember' do
      expect(team2.teammember?(bob)).to eq true
      assert_permit bob, team2.teammembers.new, :create?
    end

    it 'cannot add a teammember as non-teammeber' do
      expect(team2.teammember?(alice)).to eq false
      refute_permit alice, team2.teammembers.new, :create?
    end

    it 'cannot add a teammember to personal team' do
      expect(personal_team_bob.teammember?(bob)).to eq(true)
      refute_permit bob, personal_team_bob.teammembers.new, :create?
    end
  end

  context 'destroy' do
    it 'can remove a teammember as a teammember' do
      expect(team2.teammember?(bob)).to eq true
      assert_permit bob, team2.teammembers.new, :destroy?
    end
  end

  it 'cannot remove a teammember as non-teammeber' do
    expect(team2.teammember?(alice)).to eq false
    refute_permit alice, team2.teammembers.first, :destroy?
  end

  it 'cannot remove a teammember of personal_team' do
    expect(personal_team_bob.teammember?(bob)).to eq(true)
    refute_permit bob, personal_team_bob.teammembers.first, :destroy?
  end
end
