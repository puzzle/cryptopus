# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

describe OidcClient do

  let(:client) { described_class.new }

  before { enable_openid_connect }

  context '#external_login_url' do
    it 'returns auth servers url for user login' do
      redirect_url, state = client.external_login_url(jump_to: '/accounts/42')
      base, params = redirect_url.split('?')
      expect(base).to eq('https://oidc.example.com/auth/realms/cryptopus/protocol/openid-connect/auth')
      expect(params).to include(
        'redirect_uri=http%3A%2F%2Fwww.example.com%2Fsession%2Foidc%3Fjump_to%3D%252Faccounts%252F42'
      )
      expect(state.length).to eq(32)
    end
  end

  context '#get_token_from_provider' do
    it 'retrieves token from openid connect auth server' do
      stub_request(:post, 'https://oidc.example.com/auth/realms/cryptopus/protocol/openid-connect/token').
        with(
          body: { code: 'code-from-client42', grant_type: 'authorization_code', state: 'state42', redirect_uri: 'http://localhost/test' },
          headers: {
            Authorization: 'Basic Y3J5cHRvcHVzOnZlcnlzZWNyZXRzZWNyZXQ0Mg==',
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        ).to_return(status: 200, body: token_response_body, headers: {})

      code = 'code-from-client42'
      state = 'state42'
      redirect_uri = 'http://localhost/test'
      token = client.get_token_from_provider(code: code, state: state, redirect_uri: redirect_uri)
    end
  end

  private

  def token_response_body
    {
      access_token: 'SlAV32hkKG',
      token_type: 'Bearer',
      refresh_token: '8xLOxBtZp8',
      expires_in: 3600,
      id_token: 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6ICJodHRwOi8vc2VydmVyLmV4YW1wbGUuY29tIiwKICJzdWIiOiAiMjQ4Mjg5NzYxMDAxIiwKICJhdWQiOiAiczZCaGRSa3F0MyIsCiAibm9uY2UiOiAibi0wUzZfV3pBMk1qIiwKICJleHAiOiAxMzExMjgxOTcwLAogImlhdCI6IDEzMTEyODA5NzAKfQ.ggW8hZ1EuVLuxNuuIJKX_V8a_OMXzR0EHR9R6jgdqrOOF4daGU96Sr_P6qJp6IcmD3HP99Obi1PRs-cwh3LO-p146waJ8IhehcwL7F09JdijmBqkvPeB2T9CJNqeGpe-gccMg4vfKjkM8FcGvnzZUN4_KSP0aAp1tOJ1zZwgjxqGByKHiOtX7TpdQyHE5lcMiKPXfEIQILVq0pc_E2DzL7emopWoaoZTF_m0_N0YzFC6g6EJbOEoRoSK5hoDalrcvRYLSrQAZZKflyuVCyixEoV9GfNQC3_osjzw2PAithfubEEBLuVVk4XUVrWOLrLl0nx7RkKU8NXNHq-rvKMzqg'
    }.to_json
  end
end
