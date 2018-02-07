require 'test_helper'

class AccountPolicyTest < PolicyTest
  context '#show' do
    test 'teammember can show account' do
      assert_permit bob, account2, :show?
    end

    test 'non teammember cannot show account' do
      refute_permit alice, account2, :show?
    end
  end

  context '#new' do
    test 'teammember can create a new account' do
      assert_permit bob, account2, :new?
    end

    test 'non teammember cannot create a new account' do
      refute_permit alice, account2, :new?
    end
  end

  context '#create' do
    test 'teammember can create a new account with keypair' do
      assert_permit bob, account2, :create?
    end

    test 'non teammember cannot create a new account with keypair' do
      refute_permit alice, account2, :create?
    end
  end

  context '#edit' do
    test 'teammember can edit account' do
      assert_permit bob, account2, :edit?
    end

    test 'non teammember cannot edit account' do
      refute_permit alice, account2, :edit?
    end
  end

  context '#update' do
    test 'teammember can update account' do
      assert_permit bob, account2, :update?
    end

    test 'non teammember cannot update account' do
      refute_permit alice, account2, :update?
    end
  end

  context '#destroy' do
    test 'teammember can destroy account' do
      assert_permit bob, account2, :destroy?
    end

    test 'non teammember cannot destroy account' do
      refute_permit alice, account2, :destroy?
    end
  end

  context '#move' do
    test 'teammember can move account' do
      assert_permit bob, account2, :move?
    end

    test 'non teammember cannot move account' do
      refute_permit alice, account2, :move?
    end
  end

  context '#scope' do
    test 'teammember receives accountlist' do
      assert_not_nil AccountPolicy::Scope.new(bob, group2).resolve
    end

    test 'non teammember cannot read accountlist' do
      assert_nil AccountPolicy::Scope.new(alice, group2).resolve
    end
  end

  private
  
  def account2
    accounts(:account2)
  end

  def group2
    groups(:group2)
  end
end
