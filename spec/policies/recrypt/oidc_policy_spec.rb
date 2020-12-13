# frozen_string_literal: true

require 'rails_helper'

describe Recrypt::OidcPolicy do
  include PolicyHelper

  let(:headless_policy) { :'Recrypt::Oidc' }

  let(:oidc_user) do
    user = users(:bob)
    user.auth = 'oidc'
    user
  end

  it 'db user can migrate to oidc if openid enabled' do
    enable_openid_connect
    expect(bob).not_to be_oidc

    expect(authorized?(bob, :new?)).to eq(true)
    expect(authorized?(bob, :create?)).to eq(true)
  end

  it 'db user cannot migrate to oidc if auth provider db' do
    expect(authorized?(oidc_user, :new?)).to eq(false)
    expect(authorized?(oidc_user, :create?)).to eq(false)
  end

  it 'oidc user can\'t migrate to oidc' do
    enable_openid_connect
    expect(authorized?(oidc_user, :new?)).to eq(false)
    expect(authorized?(oidc_user, :create?)).to eq(false)
  end

  private

  def authorized?(user, action)
    Pundit.policy!(user, headless_policy).public_send(action)
  end
end
