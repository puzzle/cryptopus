require 'test_helper'

class TeamPolicyTest < PolicyTest

  context '#create' do
    test 'everyone can create a new team' do
      assert_permit alice, Team.new, :create?
      assert_permit admin, Team.new, :create?

      assert_permit alice, Team.new, :new?
      assert_permit admin, Team.new, :new?
    end
  end

  context '#update' do
    test 'teammember can edit a team' do
      assert team2.teammember? bob
      assert_permit bob, team2, :edit?
    end

    test 'non-teammember cannot edit a team' do
      assert_not team2.teammember? alice
      refute_permit alice, team2, :edit?
    end

    test 'admin can edit a public team' do
      assert_not team1.private?
      assert_permit admin, team1, :edit?
    end

    test 'admin cannot edit a private team' do
      assert private_team.private?
      refute_permit admin, private_team, :edit?
    end
  end

  context '#destroy' do
    test 'non-teammember cannot delete a team'do
      assert_not team2.teammember? alice
      refute_permit alice, team2, :destroy?
    end

    test 'teammember cannot delete a team' do
      assert team2.teammember? bob
      refute_permit bob, team2, :destroy?
    end

    test 'admin can delete any team' do
      assert_permit admin, team1, :destroy?
      assert_permit admin, team2, :destroy?
      assert_permit admin, private_team, :destroy?
    end

    test 'conf admin can delete a team with only one teammember' do
      assert_permit conf_admin, team2, :destroy?
    end

    test 'conf admin cannot delete a team with more than one teammmember' do
      refute_permit conf_admin, team1, :destroy?
    end
  end
  
  context 'admin teams' do
    test 'admin can list all teams' do
      assert_permit admin, Team, :index_all?
    end
    
    test 'conf_admin can list all teams' do
      assert_permit conf_admin, Team, :index_all?
    end
    
    test 'user cannot list all teams' do
      refute_permit bob, Team, :index_all?
    end
  end

  context '#scope' do
    test 'admin sees all non-private teams' do
      teams = TeamPolicy::Scope.new(admin, Team).resolve

      assert_equal Team.where(private: false), teams
    end

    test 'user can only list teams where member' do
      team1.teammembers.find_by(user_id: bob.id).destroy!
      bobs_teams = TeamPolicy::Scope.new(bob, Team).resolve

      assert_equal 1, bobs_teams.count
      assert_equal bob.teams, bobs_teams
    end
  end
    
  test 'admin may list all teams' do
    teams = TeamPolicy::Scope.new(admin, Team).resolve_all

    assert_equal Team.all, teams
  end
  
  test 'conf admin may list all teams' do
    teams = TeamPolicy::Scope.new(admin, Team).resolve_all

    assert_equal Team.all, teams
  end

  test 'user may not list all teams' do
    teams = TeamPolicy::Scope.new(bob, Team).resolve_all

    assert_nil teams
  end
  
  context '#add' do
    test 'teammember can add a teammember' do
      assert team2.teammember? bob
      assert_permit bob, team2, :add_member?
    end

    test 'non-teammember cannot add a teammember' do
      assert_not team2.teammember? alice
      refute_permit alice, team2, :add_member?
    end
  end
  
  context '#remove' do
    test 'teammember can remove a teammember' do
      assert team2.teammember? bob
      assert_permit bob, team2, :remove_member?
    end

    test 'non-teammember cannot remove a teammember' do
      assert_not team2.teammember? alice
      refute_permit alice, team2, :remove_member?
    end
  end

  private

  def team1
    teams(:team1)
  end

  def team2
    teams(:team2)
  end

  def private_team
    Fabricate(:private_team)
  end
end
