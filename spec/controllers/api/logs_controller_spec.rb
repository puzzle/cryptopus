# frozen_string_literal: true

require 'spec_helper'

describe Api::LogsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:id_one) { encryptables(:id) }

  context 'GET index' do
    it 'calls index action' do
      login_as(:alice)
      get :index, params: { encryptable_id: :id_one }
    end
  end
end
