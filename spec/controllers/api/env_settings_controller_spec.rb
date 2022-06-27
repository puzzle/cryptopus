# frozen_string_literal: true

require 'spec_helper'

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

    it 'returns fallback info if present' do
      FallbackInfo.create!(info: 'Fallback - dump import 15.07.2022 - read only!')

      login_as(:bob)

      get :index

      expect(json['fallback_info']).to eq('Fallback - dump import 15.07.2022 - read only!')
    end
  end
end
