# frozen_string_literal: true

require 'spec_helper'

describe Api::LogsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:id1) { encryptables(:id) }

  context 'GET index' do
    it 'something' do
      login_as(:alice)
      get :index, params: { encryptable_id: :id1 }
    end
  end
end
