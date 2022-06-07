# frozen_string_literal: true

require 'spec_helper'

describe Api::SharedEncryptablesController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }

  context 'POST create' do
    it 'send new request with encryptable_id and receiver_id' do
      set_auth_headers
      login_as(:alice)

      credentials1 = encryptables(:credentials1)

      shared_encryptable_params = {
        data: {
          encryptable_id: credentials1.id,
          receiver_id: bob.id
        }
      }
      post :create, params: shared_encryptable_params, xhr: true

      expect(response).to have_http_status(204)
    end

    it 'send new request with non valid encryptable_id and non valid receiver_id' do
      set_auth_headers
      login_as(:alice)

      credentials1 = encryptables(:credentials1)

      shared_encryptable_params = {
        data: {
          encryptable_id: 1,
          receiver_id: bob.id
        }
      }
      post :create, params: shared_encryptable_params, xhr: true

      expect(response).to have_http_status(404)

      shared_encryptable_params = {
        data: {
          encryptable_id: credentials1,
          receiver_id: 1
        }
      }
      post :create, params: shared_encryptable_params, xhr: true

      expect(response).to have_http_status(404)
    end
  end

  def set_auth_headers
    request.headers['Authorization-User'] = alice.username
    request.headers['Authorization-Password'] = Base64.encode64('password')
  end
end
