# frozen_string_literal: true

require 'spec_helper'

describe Api::LogsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:credentials1) { encryptables(:credentials1) }
  let(:credentials2) { encryptables(:credentials2) }

  context 'GET index' do
    it 'returns right amount of logs' do
      login_as(:alice)
      credentials1.touch
      credentials1.touch
      get :index, params: { encryptable_id: credentials1.id }
      expect(data.count).to eq 2
    end
  end
end
