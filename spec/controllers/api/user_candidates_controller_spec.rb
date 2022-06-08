# frozen_string_literal: true

require 'spec_helper'

describe Api::UserCandidatesController do
  include ControllerHelpers

  context 'GET candidates' do
    it 'returns team member candidates for team' do
      login_as(:admin)
      team = Team::Shared.create(users(:admin), name: 'foo')

      get :index, params: { team_id: team }, xhr: true

      candidates = json['data']

      expect(candidates.size).to eq 3
      candidate_labels = candidates.collect { |c| c['attributes']['label'] }
      expect(candidate_labels).to include('Alice test (alice)')
      expect(candidate_labels).to include('Bob test (bob)')
      expect(candidate_labels).to include('Tux Miller (tux)')

      expect(candidate_labels).not_to include('Admin test (admin)')
    end

    it 'returns error when not team member' do
      login_as(:alice)
      team = Team::Shared.create(users(:admin), name: 'foo')

      get :index, params: { team_id: team }, xhr: true

      expect(response).to have_http_status(403)
    end

    it 'returns all users without current_user' do

      login_as(:admin)
      Team::Shared.create(users(:admin), name: 'foo')

      get :index, params: {}, xhr: true

      candidates = json['data']

      expect(candidates.size).to eq 4

      candidate_labels = candidates.collect { |c| c['attributes']['label'] }
      expect(candidate_labels).to include('Alice test (alice)')
      expect(candidate_labels).to include('Bob test (bob)')
      expect(candidate_labels).to include('Tux Miller (tux)')
      expect(candidate_labels).to include('Root test (root)')

      expect(candidate_labels).not_to include('Admin test (admin)')

    end
  end
end
