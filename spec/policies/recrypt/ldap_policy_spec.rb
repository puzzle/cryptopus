# frozen_string_literal: true

require 'spec_helper'

describe Recrypt::LdapPolicy do
  include PolicyHelper

  let(:headless_policy) { :'Recrypt::Ldap' }

  let(:ldap_user) do
    user = users(:bob)
    user.auth = 'ldap'
    user
  end

  it 'non-ldap user cannot set a new ldap password' do
    enable_ldap

    expect(authorized?(users(:bob), :new?)).to eq(false)
    expect(authorized?(users(:bob), :create?)).to eq(false)
  end

  it 'ldap user can set a new ldap password or create a recrypt request' do
    enable_ldap

    expect(authorized?(ldap_user, :new?)).to eq(true)
    expect(authorized?(ldap_user, :create?)).to eq(true)
  end

  private

  def authorized?(user, action)
    Pundit.policy!(user, headless_policy).public_send(action)
  end
end
