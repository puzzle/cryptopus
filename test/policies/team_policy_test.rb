require 'test_helper'

class TeamPolicyTest < PolicyTest


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

    test 'admin cannot edit a non-public team' do

    end
  end

  context '#destroy' do
    test 'non-teammember cannot delete a team'do

    end

    test 'teammember can delete a team' do

    end

    test 'admin can delete any team' do

    end
  end

#  context '#scope' do
#    test 'admin sees all non-private teams' do
#      assert_not_nil policy_scope(admin, Team)
#    end
#
#    test 'user can see all teams he is a part of' do
#      assert_not_nil policy_scope(bob, Team)
#    end
#
#    test 'user cannot see teams he isnt a part of' do
#
#    end
#  end
  #
  private

  def team2
    teams(:team2)
  end

  def non_public_team
  end
end
