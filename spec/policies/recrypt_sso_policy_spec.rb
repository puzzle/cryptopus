# frozen_string_literal: true

require 'rails_helper'

describe RecryptSsoPolicy do
  include PolicyHelper

  let(:keycloak_user) do
    user = users(:bob)
    user.auth = 'keycloak'
    user
  end

  context 'as non-keycloak user' do
    it 'db user can migrate to keycloak' do
      enable_keycloak
      expect(bob).to_not be_keycloak
      assert_permit bob, :recryptSso, :new?
      assert_permit bob, :recryptSso, :create?
    end
  end

  context 'as keycloak user' do
    it 'keycloak user can\'t migrate to keycloak' do
      refute_permit keycloak_user, :recryptSso, :new?
      refute_permit keycloak_user, :recryptSso, :create?
    end
  end
end
