# frozen_string_literal: true

require 'rails_helper'

describe Api::Teams::CandidatesController do
  include ControllerHelpers

  context 'GET candidates' do
    it 'returns team member candidates for new team' do
      login_as(:admin)
      team = Team.create(users(:admin), name: 'foo')

      get :index, params: { team_id: team }, xhr: true

      candidates = json['data']['user/humen']

      expect(candidates.size).to eq 3
      expect(candidates.any? { |c| c['label'] == 'Alice test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Bob test' }).to be true
      expect(candidates.any? { |c| c['label'] == 'Tux Miller' }).to be true
    end
  end

end
