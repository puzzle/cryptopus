# frozen_string_literal: true

require 'rails_helper'
require 'user/api'

describe User::ApiPolicy do
  include PolicyHelper

  let!(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }

  context '#index' do
    it 'shows everyone their api users' do
      assert_permit alice, User::Api, :index?
      assert_permit bob, User::Api, :index?
      assert_permit admin, User::Api, :index?
    end
  end

  context '#create' do
    it 'lets everyone create a new api user' do
      assert_permit alice, User::Api.new, :create?
      assert_permit bob, User::Api.new, :create?
      assert_permit admin, User::Api.new, :create?
    end
  end

  context '#show' do
    it 'shows a user his api user' do
      assert_permit bob, api_user, :show?
    end

    it 'does not show a user a foreign api user' do
      refute_permit alice, api_user, :show?
    end
  end

  context '#update' do
    it 'lets a user update his api user' do
      assert_permit bob, api_user, :update?
    end

    it 'lets a user cannot update a foreign api user' do
      refute_permit alice, api_user, :update?
    end
  end

  context '#destroy' do
    it 'lets a user delete his api user' do
      assert_permit bob, api_user, :destroy?
    end

    it 'lets a user not delete a foreign api user' do
      refute_permit alice, api_user, :destroy?
    end
  end

  context '#lock' do
    it 'lets a user lock his api user' do
      assert_permit bob, api_user, :lock?
    end

    it 'lets a user not lock a foreign api user' do
      refute_permit alice, api_user, :lock?
    end
  end

  context '#unlock' do
    it 'lets a user unlock his api user' do
      assert_permit bob, api_user, :unlock?
    end

    it 'lets a user not unlock a foreign api user' do
      refute_permit alice, api_user, :unlock?
    end
  end
end
