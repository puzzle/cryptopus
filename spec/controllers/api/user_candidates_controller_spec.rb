# frozen_string_literal: true

require 'spec_helper'

describe Api::UserCandidatesController do
  include ControllerHelpers

  context 'GET candidates' do
    it 'returns team member candidates for new team' do
      login_as(:admin)
      team = Team::Shared.create(users(:admin), name: 'foo')

      get :index, params: { team_id: team }, xhr: true

      candidates = json['data']

      expect(candidates.size).to eq 3
      expect(candidates.any? { |c| c['attributes']['label'] == 'Alice test (alice)' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Bob test (bob)' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Tux Miller (tux)' }).to be true

      expect(candidates.any? { |c| c['attributes']['label'] == 'Admin test (admin)' }).to be false
    end

    it 'returns all users without current_user' do

      login_as(:admin)
      Team::Shared.create(users(:admin), name: 'foo')

      get :index, params: {}, xhr: true

      candidates = json['data']

      expect(candidates.size).to eq 4
      expect(candidates.any? { |c| c['attributes']['label'] == 'Alice test (alice)' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Bob test (bob)' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Tux Miller (tux)' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Root test (root)' }).to be true

      expect(candidates.any? { |c| c['attributes']['label'] == 'Admin test (admin)' }).to be false
    end

  end

end
