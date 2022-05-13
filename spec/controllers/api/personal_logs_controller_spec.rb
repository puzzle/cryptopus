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
      login_as(:alice)
      PaperTrail.request(whodunnit: alice.id) do
        credentials1.touch
        credentials1.touch
      end

      get :index, params: {}
      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq 'alice'
    end

    it 'returns sorted results' do
      login_as(:bob)
      PaperTrail.request(whodunnit: bob.id) do
        credentials1.touch
        credentials1.touch
      end
      get :index, params: {}
      expect(data.first['attributes']['created_at']).to be > data.second['attributes']['created_at']
    end

    it 'only returns your logs' do
      login_as(:alice)
      PaperTrail.request(whodunnit: alice.id) do
        credentials1.touch
        credentials1.touch
      end

      login_as(:bob)
      PaperTrail.request(whodunnit: bob.id) do
        credentials1.touch
      end

      get :index, params: {}
      expect(data.count).to eq 1
      expect(data.first['attributes']['username']).to eq 'bob'

      login_as(:alice)
      get :index, params: {}
      expect(data.count).to eq 2
      expect(data.first['attributes']['username']).to eq 'alice'
      expect(data.last['attributes']['username']).to eq 'alice'
    end
  end
end
