# frozen_string_literal: true

require 'rails_helper'

describe OidcClient do

  let(:client) { described_class.new }

  before do
    enable_openid_connect
  end

  context '#external_login_url' do

    it 'returns auth servers url for user login' do
      redirect_url = client.external_login_url(jump_to: '/accounts/42')
      base, params = redirect_url.split('?')
      expect(base).to eq('https://oidc.example.com/auth/realms/cryptopus/protocol/openid-connect/auth')
      expect(params).to include(
        'redirect_uri=http%3A%2F%2Fwww.example.com%2Fsession%2Foidc%3Fjump_to%3D%252Faccounts%252F42'
      )
    end

  end
end
