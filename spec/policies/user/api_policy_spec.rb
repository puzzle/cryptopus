# frozen_string_literal: true

require 'spec_helper'
require 'user/api'

describe User::ApiPolicy do
  include PolicyHelper

  let(:alice) { users(:alice) }
  let(:bob) { users(:bob) }
  let!(:api_user) { bob.api_users.create!(description: 'my sweet api user') }
  let!(:foreign_api_user) { alice.api_users.create!(description: 'my sweet foreign api user') }

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

    it 'shows an api user his api user' do
      assert_permit api_user, api_user, :show?
    end

    it 'shows an api user a foreign api user' do
      refute_permit foreign_api_user, api_user, :show?
    end
  end

  context '#update' do
    it 'lets a user update his api user' do
      assert_permit bob, api_user, :update?
    end

    it 'does not let a user update a foreign api user' do
      refute_permit alice, api_user, :update?
    end

    it 'lets an api user update his api user' do
      assert_permit api_user, api_user, :show?
    end

    it 'does not let an api user update a foreign api user' do
      refute_permit foreign_api_user, api_user, :show?
    end
  end

  context '#destroy' do
    it 'lets a user delete his api user' do
      assert_permit bob, api_user, :destroy?
    end

    it 'does not let a user delete a foreign api user' do
      refute_permit alice, api_user, :destroy?
    end

    it 'lets an api user delete his api user' do
      assert_permit api_user, api_user, :show?
    end

    it 'does not let an api user delete a foreign api user' do
      refute_permit foreign_api_user, api_user, :show?
    end
  end

  context '#lock' do
    it 'lets a user lock his api user' do
      assert_permit bob, api_user, :lock?
    end

    it 'does not let a user lock a foreign api user' do
      refute_permit alice, api_user, :lock?
    end

    it 'lets an api user lock his api user' do
      assert_permit api_user, api_user, :show?
    end

    it 'does not let an api user lock a foreign api user' do
      refute_permit foreign_api_user, api_user, :show?
    end
  end

  context '#unlock' do
    it 'lets a user unlock his api user' do
      assert_permit bob, api_user, :unlock?
    end

    it 'does not let a user unlock a foreign api user' do
      refute_permit alice, api_user, :unlock?
    end

    it 'lets an api user unlock his api user' do
      assert_permit api_user, api_user, :show?
    end

    it 'does not let an api user unlock a foreign api user' do
      refute_permit foreign_api_user, api_user, :show?
    end
  end
end
