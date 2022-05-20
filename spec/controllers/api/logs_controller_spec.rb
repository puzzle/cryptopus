# frozen_string_literal: true

require 'spec_helper'

describe Api::LogsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:credentials1) { encryptables(:credentials1) }

  context 'GET index' do
    it 'returns right amount of logs' do
      login_as(:alice)
      log_read_access(alice.id, credentials1)
      log_read_access(alice.id, credentials1)

      get :index, params: { encryptable_id: credentials1.id }
      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq 'alice'
    end

    it 'returns sorted results' do
      login_as(:alice)
      log_read_access(alice.id, credentials1)
      log_read_access(alice.id, credentials1)

      get :index, params: { encryptable_id: credentials1.id }
      expect(data.first['attributes']['created_at']).to be > data.second['attributes']['created_at']
    end

    it 'denies access if not in team' do
      login_as(:alice)

      team2 = teams(:team2)
      encryptable = team2.folders.first.encryptables.first

      get :index, params: { encryptable_id: encryptable.id }
      expect(response.status).to be 403
    end
  end

  def log_read_access(user_id, credential)
    v = credential.paper_trail.save_with_version
    v.whodunnit = user_id
    v.event = :viewed
    v.created_at = DateTime.now
    v.save!
  end
end
