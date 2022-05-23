# frozen_string_literal: true

require 'spec_helper'

describe Api::PersonalLogsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:credentials1) { encryptables(:credentials1) }

  context 'GET index' do
    it 'returns right amount of logs' do
      log_read_access(alice.id, credentials1)
      log_read_access(alice.id, credentials1)

      login_as(:alice)
      get :index, params: {}
      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq 'alice'
    end

    it 'returns sorted results' do
      log_read_access(alice.id, credentials1)
      log_read_access(alice.id, credentials1)

      login_as(:alice)
      get :index, params: {}
      expect(data.first['attributes']['created_at']).to be > data.second['attributes']['created_at']
    end

    it 'only returns your logs' do
      log_read_access(alice.id, credentials1)
      log_read_access(alice.id, credentials1)

      log_read_access(bob.id, credentials1)

      login_as(:bob)
      get :index, params: {}
      expect(data.count).to eq 1
      expect(data.first['attributes']['username']).to eq 'bob'

      login_as(:alice)
      get :index, params: {}
      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq 'alice'
      expect(data.last['attributes']['username']).to eq 'alice'
    end

    it 'returns nothing when not logged in' do
      log_read_access(alice.id, credentials1)
      log_read_access(alice.id, credentials1)

      get :index, params: {}
      expect(data).to eq nil
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
