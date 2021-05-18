# frozen_string_literal: true

require 'spec_helper'

describe Api::Admin::SettingsController do
  include ControllerHelpers

  let(:country_source_whitelist) { settings(:country_source_whitelist) }
  let(:ip_whitelist) { settings(:ip_whitelist) }

  context 'GET index' do
    it 'returns all settings' do
      login_as(:admin)

      get :index, xhr: true
      require "pry"; binding.pry
      
      firstAttributes = data.first['attributes']
      expect(firstAttributes['value']).to eq ['0.0.0.0', '192.168.10.0']

      secondAttributes = data.second['attributes']
      expect(secondAttributes['value']).to eq ['CH', 'DE']

      expect(data.size).to be(2)
      expect(included).to be(nil)
    end
  end
  context 'PUT update' do
    it 'updates settings' do
      login_as(:admin)

      settings_params = {
        data: {
        [
          {
            id: country_source_whitelist.id,
            type: 'setting_ip_ranges',
            attributes: {
              key: 'ip_whitelist',
              value: ['0.0.0.0', '192.168.255.0']
            }
          },
          {
            id: ip_whitelist.id,
            type: 'setting_country_codes',
            attributes: {
              key: 'country_source_whitelist',
              value: ["DE", "US"]
            }
          }
        ]
        }
      }
      patch :update, params: settings_params, xhr: true

      country_source_whitelist.reload
      ip_whitelist.reload

      expect(country_source_whitelist['value']).to eq ['0.0.0.0', '192.168.255.0']
      expect(ip_whitelist['value']).to eq ["DE", "US"]

      expect(response).to have_http_status(200)
    end
  end
end



