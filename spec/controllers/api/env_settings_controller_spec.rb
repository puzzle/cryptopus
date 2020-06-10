# frozen_string_literal: true

require 'rails_helper'

describe Api::EnvSettingsController do
  include ControllerHelpers

  before do
    ENV['SENTRY_DSN_FRONTEND'] = '123456'
  end

  context 'GET index' do

    it 'returns env_settings' do
      get :index

      expect(json['sentry']).to eq('123456')
    end
  end
end
