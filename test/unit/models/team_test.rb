require 'test_helper'
class TeamTest <  ActiveSupport::TestCase
  test 'removes all assoziated groups, accounts, teammembers if team is destroyed' do
    team1 = teams(:team1)
    account1 = accounts(:account1)
    group1 = groups(:group1)

    team1.destroy

    assert team1.destroyed?
    assert_raises(ActiveRecord::RecordNotFound) { Group.find(group1.id) }
    assert_raises(ActiveRecord::RecordNotFound) { Account.find(account1.id) }
    assert Teammember.where(team_id: team1.id).empty?
    #TODO check items also removed
  end
end