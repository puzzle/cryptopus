# frozen_string_literal: true

require 'rails_helper'

describe Api::EnvSettingsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }

  before do
    ENV['SENTRY_DSN_FRONTEND'] = '123456'
  end

  context 'GET index' do

    it 'returns env_settings' do
      login_as(:bob)

      get :index

      expect(json['sentry']).to eq('123456')
      expect(json['current_user']['id']).to eq(bob.id)
    end
  end
end
