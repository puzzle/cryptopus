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
  test "returns teammember candidates" do
    teammembers(:team1_bob).destroy

    team = teams(:team1)
    candidates = team.teammember_candidates

    refute_includes candidates, users(:root)
    refute_includes candidates, users(:admin)
    refute_includes candidates, users(:alice)
    assert_includes candidates, users(:bob)
  end

  test "does not add user if already teammember" do
    team = teams(:team1)
    plaintext_private_key = decrypt_private_key(alice)
    plaintext_team_pw = team.decrypt_team_password(alice, plaintext_private_key)

    exception = assert_raises do
      team.add_user(bob, plaintext_team_pw)
    end

    assert_match /user is already team member/, exception.message
  end

  test "adds first user to team" do
    team = Team.create(name: 'foo')
    plaintext_private_key = decrypt_private_key(alice)

    team.add_user(alice)

    assert_equal 1, team.teammembers.count
    teammember = team.teammembers.first
    assert_equal alice, teammember.user
  end

  test "adds user to team" do
    team = teams(:team1)
    plaintext_team_password = team.
      decrypt_team_password(bob, decrypt_private_key(bob))

    team.remove_user(alice)

    assert_difference('team.teammembers.count', 1) do
      team.add_user(alice, plaintext_team_password)
    end

    alice_plaintext_team_password = team.
      decrypt_team_password(alice, decrypt_private_key(alice))

    assert_equal plaintext_team_password, alice_plaintext_team_password
  end

  test "removes user from team" do
    team = teams(:team1)

    assert_difference('team.teammembers.count', -1) do
      team.remove_user(alice)
    end
  end

  test "does not remove user from team if not team member" do
    team = teams(:team1)
    team.remove_user(alice)

    exception = assert_raises do
      team.remove_user(alice)
    end

    assert_match /user is not a team member/, exception.message
  end

  private
  def alice
    users(:alice)
  end

  def bob
    users(:bob)
  end

  def decrypt_private_key(user)
    user.decrypt_private_key('password')
  end

end
