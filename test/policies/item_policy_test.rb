require 'test_helper'

class ItemPolicyTest < PolicyTest

  before(:each) do
    remove_alice_from_team
  end

  context '#show' do
    test 'teammember can show item' do
      assert_permit bob, item1, :show?
    end

    test 'non teammember cannot show item' do
      refute_permit alice, item1, :show?
    end
  end

  context '#new' do
    test 'teammember can create a new item' do
      assert_permit bob, item1, :new?
    end

    test 'non teammember cannot create a new item' do
      refute_permit alice, item1, :new?
    end
  end

  context '#create' do
    test 'teammember can create a new item with keypair' do
      assert_permit bob, account, :create_item?
    end

    test 'non teammember cannot create a new item with keypair' do
      refute_permit alice, account, :create_item?
    end
  end
  
  context '#destroy' do
    test 'teammember can destroy item' do
      assert_permit bob, item1, :destroy?
    end

    test 'non teammember cannot destroy item' do
      refute_permit alice, item1, :destroy?
    end
  end

  private

  def remove_alice_from_team
    team1 = Team.find_by(name: 'team1')
    teammember = team1.teammembers.find_by(id: 2367674)
    teammember.destroy!
  end
  
  def account
    Account.find_by(accountname: 'account2')
  end

  def item1
    items(:item1)
  end
end
