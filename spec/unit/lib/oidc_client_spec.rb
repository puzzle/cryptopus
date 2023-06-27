# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

describe OidcClient do

  let(:client) { described_class.new }

  before { enable_openid_connect }

  context '#external_login_url' do
    it 'returns auth servers url for user login' do
      redirect_url, state = client.external_login_url
      base, params = redirect_url.split('?')
      params = URI.decode_www_form(params).to_h
      expect(base).to eq('https://oidc.example.com:8180/auth/realms/cryptopus/protocol/openid-connect/auth')
      expect(params['scope']).to eq('custom openid')
      expect(params['redirect_uri']).to eq('http://cryptopus.example.com/session/oidc')
      expect(state.length).to eq(32)
    end
  end

  context '#get_id_token' do
    it 'retrieves id token from openid connect auth server' do

      code = '9854fb0a-9414-4385-a35d-37e982aad4ce.7ad42cae-5b68-4e3e-ba47-09f923281224.5534245e-0041-4a42-b973-c33a58977d21' # rubocop:disable Layout/LineLength

      state = SecureRandom.hex(16)

      stub_request(:post, 'https://oidc.example.com:8180/auth/realms/cryptopus/protocol/openid-connect/token').
        with(
          body: { code: code, grant_type: 'authorization_code', state: state,
                  redirect_uri: 'http://cryptopus.example.com/session/oidc' },
          headers: {
            Authorization: 'Basic Y3J5cHRvcHVzOnZlcnlzZWNyZXRzZWNyZXQ0Mg==',
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        ).to_return(status: 200, body: token_response_body, headers: {})

      stub_request(:get, 'http://oidc.example.com/auth/realms/cryptopus/protocol/openid-connect/certs').
        with(
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent': 'Ruby'
          }
        ).to_return(status: 200, body: public_key_response, headers: {})


      attrs = client.get_id_token(code: code, state: state).raw_attributes
      expect(attrs['cryptopus_pk_secret_base']).to eq('b9803ef3a1b43572536e1fbe13a5fd4a')
      expect(attrs['preferred_username']).to eq('alice')
      expect(attrs['given_name']).to eq('alice')
      expect(attrs['family_name']).to eq('bli')
    end
  end

  private

  def token_response_body
    {
      access_token: 'SlAV32hkKG',
      token_type: 'Bearer',
      refresh_token: '8xLOxBtZp8',
      expires_in: 3600,
      id_token: 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI5eWNINWNkNDhGZHY0WHdRRDV2VUozSkphX0lscDNTN1J5YUJPYU9DUWFVIn0.eyJleHAiOjE2MDc1ODM0MDUsImlhdCI6MTYwNzU4MzEwNSwiYXV0aF90aW1lIjoxNjA3NTgxMzMyLCJqdGkiOiI0OWFhZjUwYy1hMDFiLTQ1NTctYmI5ZS1iMDBjNzc2ZmM4NzMiLCJpc3MiOiJodHRwOi8va2V5Y2xvYWs6ODE4MC9hdXRoL3JlYWxtcy9jcnlwdG9wdXMiLCJhdWQiOiJjcnlwdG9wdXMiLCJzdWIiOiIzNzdhZGE1Ni02ZWU2LTQ4YmMtODIwMS01MTk1NjhiNjQwMjkiLCJ0eXAiOiJJRCIsImF6cCI6ImNyeXB0b3B1cyIsIm5vbmNlIjoiZDM4NGJkNmZmZmZkNzIwYzdjZDEyZDJhMTBlZWZiNDQiLCJzZXNzaW9uX3N0YXRlIjoiN2FkNDJjYWUtNWI2OC00ZTNlLWJhNDctMDlmOTIzMjgxMjI0IiwiYWNyIjoiMCIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiY3J5cHRvcHVzX3BrX3NlY3JldF9iYXNlIjoiYjk4MDNlZjNhMWI0MzU3MjUzNmUxZmJlMTNhNWZkNGEiLCJuYW1lIjoiYWxpY2UgYmxpIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiYWxpY2UiLCJnaXZlbl9uYW1lIjoiYWxpY2UiLCJmYW1pbHlfbmFtZSI6ImJsaSJ9.fz9CO37YXaTBL-BfVpahZ9glxeUBAJxLvTiS7Yn16poMgYgpHCgIUweH8hz_yN5U1E2NTCYk70L-l9DfW4JYmaCTiOMP0Par389fjhy1hdAGwVouIPT0antQEw5eRnKIOReoxU_ViYyLzQ5O3xmb4c7aMwijZb_d8b1mbLMfKYOos8jdLze6TWcwdxq_XL3PE99OGE8IB_SkZpV4jUlRT7CcUj39XEoQt2mVl2cLlYtjSxvS4i9tvE2jlgpjNyd-jrlor9kX6ZFzuckPeeztFhKcGnvbjIrw1KCnFP-l51TM6TXKbgqGfzyieZr3o_Ffc2-Z2CuPAO-nPKLVtCNRoA' # rubocop:disable Layout/LineLength

    }.to_json
  end

  def public_key_response
    {
      'keys': [
        {
          'kid': '9ycH5cd48Fdv4XwQD5vUJ3JJa_Ilp3S7RyaBOaOCQaU',
          'kty': 'RSA',
          'alg': 'RS256',
          'use': 'sig',
          'n': 'hUldnFWCmI8eiolpJTS8wFYa4tKcfXD4RCqTy2EgcC89tE3VkXMsyzzIG2SPnxTeOB_h1O__z1VwwKd4UMGxbp8anbI-42atqIXsxVGXaZbTuV6Det-pzFPmkpKQv9MPJCggfq4Z5VfoyB8Q70yEanS7kH8JoQoH4QIkf8Ee6jm2kBEjfSKBqkexEnTfeK-oI5wyjO_YwNsHmcSQKio0O7QVcFMeIhBRs1vVJxU6p_swzwsa3jjis9u8xDis1vDrh3IntvfTrcNVyUtAyUOcTFlCkDga8OdNR_aYOZnK76XK1Stzh9zofZCzcO193uKPqeUBFsPe-iLps2FZbpreCw', # rubocop:disable Layout/LineLength

          'e': 'AQAB',
          'x5c': [
            'MIICoTCCAYkCBgF2RkvabTANBgkqhkiG9w0BAQsFADAUMRIwEAYDVQQDDAljcnlwdG9wdXMwHhcNMjAxMjA5MDY1NzI0WhcNMzAxMjA5MDY1OTA0WjAUMRIwEAYDVQQDDAljcnlwdG9wdXMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCFSV2cVYKYjx6KiWklNLzAVhri0px9cPhEKpPLYSBwLz20TdWRcyzLPMgbZI+fFN44H+HU7//PVXDAp3hQwbFunxqdsj7jZq2ohezFUZdpltO5XoN636nMU+aSkpC/0w8kKCB+rhnlV+jIHxDvTIRqdLuQfwmhCgfhAiR/wR7qObaQESN9IoGqR7ESdN94r6gjnDKM79jA2weZxJAqKjQ7tBVwUx4iEFGzW9UnFTqn+zDPCxreOOKz27zEOKzW8OuHcie299Otw1XJS0DJQ5xMWUKQOBrw501H9pg5mcrvpcrVK3OH3Oh9kLNw7X3e4o+p5QEWw976IumzYVlumt4LAgMBAAEwDQYJKoZIhvcNAQELBQADggEBADoifCEIMoDlHiF0K9nlrq+macCQrnqcITxMVD06GkTqiwn4nGzLK092mja9XycQbRkDtg6tW01bNGy3BbpZUPo9UL1fSxJpKUuosX2PHCD9GY719JFp2GRcSUk+8CiQ+cmTJzrBWDi04yDsS9WCZFZgAeWJkUU96USk155FaQoSGTBud8Se7/db8HzYelIJG8ldmFd9qrKoTO7N6qC7d2LX+dBmfv59q1sIZNoNCce9lv0F23sVkjNyXMVxl8Q3vM8aCeFeL/teDv6gIe2CHmfp3jgWHt3Ntl6BKSpBs1AIXe51eY492BEuKSD01vMDZd8vGhItDB28YTmGRX1Q684=' # rubocop:disable Layout/LineLength

          ],
          'x5t': 'cyTfDzctZdk0thAm7rkFD6Z3FCU',
          'x5t#S256': 'yY_4XrdKibHtFOs0uYE9zxlZ62SE60InTRK0tjQ4I5Y'
        }
      ]
    }.to_json
  end
end
