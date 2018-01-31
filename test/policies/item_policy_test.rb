require 'test_helper'

class ItemPolicyTest < PolicyTest
  context '#show' do
    test 'teammember can show item' do
      Item.any_instance.expects(:account)
                       .returns(account)

      assert_permit bob, item1, :show?
    end

    test 'non teammember cannot show item' do
      Item.any_instance.expects(:account)
                       .returns(account)

      refute_permit alice, item1, :show?
    end
  end

  context '#new' do
    test 'teammember can create a new item' do
      Item.any_instance.expects(:account)
                       .returns(account)

      assert_permit bob, item1, :new?
    end

    test 'non teammember cannot create a new item' do
      Item.any_instance.expects(:account)
                       .returns(account)

      refute_permit alice, item1, :new?
    end
  end

  context '#create' do
    test 'teammember can create a new item with keypair' do
      Item.any_instance.expects(:account)
                       .returns(account)
      
      assert_permit bob, item1, :create?
    end

    test 'non teammember cannot create a new item with keypair' do
      Item.any_instance.expects(:account)
                       .returns(account)

      refute_permit alice, item1, :create?
    end
  end
  
  context '#destroy' do
    test 'teammember can destroy item' do
      Item.any_instance.expects(:account)
                       .returns(account)

      assert_permit bob, item1, :destroy?
    end

    test 'non teammember cannot destroy item' do
      Item.any_instance.expects(:account)
                       .returns(account)

      refute_permit alice, item1, :destroy?
    end
  end

  private
  
  def account
    Account.find_by(id: 185855917)
  end

  def item1
    items(:item1)
  end
end
