require 'test_helper'

class TeamPolicyTest < PolicyTest
  
  context '#create' do
    test 'everyone can create a new team' do
      assert_permit alice, Team.new, :create
      assert_permit admin, Team.new, :create 

      assert_permit alice, Team.new, :new
      assert_permit admin, Team.new, :new
    end
  end

  context '#update' do
    test 'teammember can edit a team' do
      assert_permit bob, team2, :edit?
    end

    test 'non-teammember cannot edit a team' do
      refute_permit alice, team2, :edit?
    end

    test 'admin can edit a public team' do
      assert_permit admin, team2, :edit?
    end

    test 'admin cannot edit a private team' do
      refute_permit admin, private_team, :edit?
    end
  end

  context '#destroy' do
    test 'non-teammember cannot delete a team'do
      refute_permit alice, team2, :destroy?
    end

    test 'teammember can delete a team' do
      assert_permit bob, team2, :destroy?
    end

    test 'admin can delete any team' do
      assert_permit admin, team2, :destroy?
      assert_permit admin, private_team, :destroy?
    end
  end

  context '#scope' do
    test 'admin sees all non-private teams' do
      teams = policy_scope(admin, Team)
      Teams.all.each do |t|
        assert_true teams.include?(t)
      end     
    end

    test 'user can see all and only the teams he is a part of' do
      teams = policy_scope(bob, Team)
      bob.teams.each do |t|
        assert_true teams.include?(t)
      end

      teams.each do |t|
        assert_true bob.teams.include?(t)
      end
    end
  end

  private

  def team2
    teams(:team2)
  end

  def private_team
    team = teams(:team2)
    team.private = true
  end
end
