require 'test_helper'
class AccountPolicyTest < PolicyTest
  context '#show' do
    test 'teammember can show account' do
      assert_permit bob, account2, :show?
    end

    test 'non teammember cannot show account' do
      refute_permit alice, account2, :show?
    end

    test 'for team enabled api user can show account' do
      assert_permit api_bob, account2, :show?
    end
  end

  context '#new' do
    test 'teammember can create a new account' do
      assert_permit bob, account2, :new?
    end

    test 'non teammember cannot create a new account' do
      refute_permit alice, account2, :new?
    end

    test 'for team enabled api user cannot create a new account' do
      refute_permit api_bob, account2, :new?
    end
  end

  context '#create' do
    test 'teammember can create a new account with keypair' do
      assert_permit bob, account2, :create?
    end

    test 'non teammember cannot create a new account with keypair' do
      refute_permit alice, account2, :create?
    end

    test 'for team enabled api user cannot create a new account with keypair' do
      refute_permit api_bob, account2, :create?
    end
  end

  context '#edit' do
    test 'teammember can edit account' do
      assert_permit bob, account2, :edit?
    end

    test 'non teammember cannot edit account' do
      refute_permit alice, account2, :edit?
    end

    test 'for team enabled api user cannot edit account' do
      refute_permit api_bob, account2, :edit?
    end
  end

  context '#update' do
    test 'teammember can update account' do
      assert_permit bob, account2, :update?
    end

    test 'non teammember cannot update account' do
      refute_permit alice, account2, :update?
    end

    test 'for team enabled api user is allowed to update account' do
      assert_permit api_bob, account2, :update?
    end

    test 'not for team enabled api user is not allowed to update account' do
      refute_permit api_alice, account2, :update?
    end

  end

  context '#destroy' do
    test 'teammember can destroy account' do
      assert_permit bob, account2, :destroy?
    end

    test 'non teammember cannot destroy account' do
      refute_permit alice, account2, :destroy?
    end

    test 'for team enabled api user cannot destroy account' do
      refute_permit api_bob, account2, :destroy?
    end
  end

  context '#move' do
    test 'teammember can move account' do
      assert_permit bob, account2, :move?
    end

    test 'non teammember cannot move account' do
      refute_permit alice, account2, :move?
    end

    test 'for team enabled api user cannot move account' do
      refute_permit api_bob, account2, :move?
    end
  end

  private

  def account1
    accounts(:account1)
  end

  def account2
    accounts(:account2)
  end

  def group2
    groups(:group2)
  end

  def team2
    teams(:team2)
  end

  def team1
    teams(:team1)
  end

  def api_bob
    bobs_private_key = bob.decrypt_private_key('password')
    plaintext_team_password = team2.decrypt_team_password(bob, bobs_private_key)

    api_bob = bob.api_users.create
    team2.add_user(api_bob, plaintext_team_password)
    api_bob
  end

  def api_alice
    alice_private_key = alice.decrypt_private_key('password')
    plaintext_team_password = team1.decrypt_team_password(alice, alice_private_key)

    api_alice = alice.api_users.create
    team1.add_user(api_alice, plaintext_team_password)
    api_alice
  end
end
