require 'test_helper'
require 'user/api'

class User::ApiPolicyTest < PolicyTest

  context '#create' do
    test 'everyone can create a new api user' do
      assert_permit alice, User::Api.new, :create?
      assert_permit bob, User::Api.new, :create?
      assert_permit admin, User::Api.new, :create?
    end
  end
  
  context '#show' do
    test 'user can show his api user' do
      assert_permit bob, api_user, :show?
    end

    test 'user cannot show a foreign api user' do
      refute_permit alice, api_user, :show?
    end
  end

  context '#update' do
    test 'user can update his api user' do
      assert_permit bob, api_user, :update?
    end

    test 'user cannot update a foreign api user' do
      refute_permit alice, api_user, :update?
    end
  end

  context '#destroy' do
    test 'user can delete his api user'do
      assert_permit bob, api_user, :destroy?
    end

    test 'user cannot delete a foreign api user' do
      refute_permit alice, api_user, :destroy?
    end
  end
  

  context '#scope' do
    test 'user sees all his api users' do
      api_users = User::ApiPolicy::Scope.new(bob, User::Api).resolve

      assert_equal User::Api.where(human_user_id: bob.id), api_users
    end
 
    test 'user cannot see foreign api users' do
      api_users = User::ApiPolicy::Scope.new(alice, User::Api).resolve

      assert_not_equal User::Api.where(human_user_id: bob.id), api_users
    end
  end
  
  private

  def api_user
    users(:api)
  end
end
