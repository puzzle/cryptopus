require 'test_helper'
require 'user/api'

class User::ApiPolicyTest < PolicyTest

  setup :create_api_user
  
  context '#index' do
    test 'everyone sees his api users' do
      assert_permit alice, User::Api, :index?
      assert_permit bob, User::Api, :index?
      assert_permit admin, User::Api, :index?
    end
  end

  context '#create' do
    test 'everyone can create a new api user' do
      assert_permit alice, User::Api.new, :create?
      assert_permit bob, User::Api.new, :create?
      assert_permit admin, User::Api.new, :create?
    end
  end
  
  context '#show' do
    test 'user can show his api user' do
      assert_permit bob, @api_user, :show?
    end

    test 'user cannot show a foreign api user' do
      refute_permit alice, @api_user, :show?
    end
  end

  context '#update' do
    test 'user can update his api user' do
      assert_permit bob, @api_user, :update?
    end

    test 'user cannot update a foreign api user' do
      refute_permit alice, @api_user, :update?
    end
  end

  context '#destroy' do
    test 'user can delete his api user'do
      assert_permit bob, @api_user, :destroy?
    end

    test 'user cannot delete a foreign api user' do
      refute_permit alice, @api_user, :destroy?
    end
  end
  
  context '#lock' do
    test 'user can lock his api user'do
      assert_permit bob, @api_user, :lock?
    end

    test 'user cannot lock a foreign api user' do
      refute_permit alice, @api_user, :lock?
    end
  end
  
  context '#unlock' do
    test 'user can unlock his api user'do
      assert_permit bob, @api_user, :unlock?
    end

    test 'user cannot unlock a foreign api user' do
      refute_permit alice, @api_user, :unlock?
    end
  end

  private

  def create_api_user
    @api_user = users(:bob).api_users.create!(description: 'my sweet api user')
  end

end
