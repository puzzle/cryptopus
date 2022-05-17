# frozen_string_literal: true

require 'spec_helper'

describe Api::Teams::CandidatesController do
  include ControllerHelpers

  context 'GET candidates' do
    it 'returns team member candidates for new team' do
      login_as(:admin)
      team = Team::Shared.create(users(:admin), name: 'foo')

      get :index, params: { team_id: team }, xhr: true

      candidates = json['data']

      expect(candidates.size).to eq 3
      expect(candidates.any? { |c| c['attributes']['label'] == 'Alice test' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Bob test' }).to be true
      expect(candidates.any? { |c| c['attributes']['label'] == 'Tux Miller' }).to be true
    end
  end

end
