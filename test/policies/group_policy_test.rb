require 'test_helper'

class GroupPolicyTest < PolicyTest
  context '#show' do
    test 'teammember can show group' do
      assert_permit bob, group2, :show?
    end

    test 'non teammember cannot show group' do
      refute_permit alice, group2, :show?
    end
  end

  context '#new' do
    test 'teammember can create a new group' do
      assert_permit bob, group2, :new?
    end

    test 'non teammember cannot create a new group' do
      refute_permit alice, group2, :new?
    end
  end

  context '#create' do
    test 'teammember can create a new group with keypair' do
      assert_permit bob, group2, :create?
    end

    test 'non teammember cannot create a new group with keypair' do
      refute_permit alice, group2, :create?
    end
  end

  context '#edit' do
    test 'teammember can edit group' do
      assert_permit bob, group2, :edit?
    end

    test 'non teammember cannot edit group' do
      refute_permit alice, group2, :edit?
    end
  end

  context '#update' do
    test 'teammember can update group' do
      assert_permit bob, group2, :update?
    end

    test 'non teammember cannot update group' do
      refute_permit alice, group2, :update?
    end
  end

  context '#destroy' do
    test 'teammember can destroy group' do
      assert_permit bob, group2, :destroy?
    end

    test 'non teammember cannot destroy group' do
      refute_permit alice, group2, :destroy?
    end
  end

  context '#scope' do
    test 'teammember receives grouplist' do
      assert_not_nil GroupPolicy::Scope.new(bob, team2).resolve
    end

    test 'non teammember cannot read grouplist' do
      assert_nil GroupPolicy::Scope.new(alice, team2).resolve
    end
  end

  private

  def group2
    groups(:group2)
  end

  def team2
    teams(:team2)
  end
end
