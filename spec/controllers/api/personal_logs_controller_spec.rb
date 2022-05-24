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
      log_read_access(alice.id, credentials1, "2022-05-24T14:12:26.246+02:00")
      log_read_access(alice.id, credentials1, "2122-07-21T14:12:16.546+02:00")

      login_as(:alice)
      get :index, params: {}
      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq 'alice'
      expect(data.first['attributes']['description']).to eq nil
      expect(data.first['attributes']['password']).to eq nil
    end

    it 'returns sorted results' do
      log_read_access(alice.id, credentials1, "2022-05-24T14:12:26.246+02:00")
      log_read_access(alice.id, credentials1, "2022-01-14T11:12:26.246+02:00")

      login_as(:alice)
      get :index, params: {}
      expect(data.first['attributes']['created_at']).to be > data.second['attributes']['created_at']
    end

    it 'only returns your logs' do
      log_read_access(alice.id, credentials1, "2022-05-24T14:12:26.246+02:00")
      log_read_access(alice.id, credentials1, "2022-01-14T11:12:26.246+02:00")

      log_read_access(bob.id, credentials1, "2122-07-21T14:12:16.546+02:00")

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

    it 'flashes error if user not logged in' do
      get :index
      expect(errors).to eq(['flashes.api.errors.user_not_logged_in'])
    end
  end

  def log_read_access(user_id, credential, dateTime)
    v = credential.paper_trail.save_with_version
    v.whodunnit = user_id
    v.event = :viewed
    v.created_at = dateTime
    v.save!
  end
end
