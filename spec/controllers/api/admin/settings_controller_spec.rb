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
      
      firstAttributes = data.first['attributes']
      expect(firstAttributes['value']).to eq ['0.0.0.0', '192.168.10.0']

      secondAttributes = data.second['attributes']
      expect(secondAttributes['value']).to eq ['CH', 'DE']

      expect(data.size).to be(2)
      expect(included).to be(nil)
    end
  end
  context 'PUT update' do
    it 'updates ip_whitelist' do
      login_as(:admin)

      settings_params = {
        data: {
            id: ip_whitelist.id,
            attributes: {
              value: ['0.0.0.0', '192.168.255.0']
            }
          }, id: ip_whitelist.id
        }
        
        patch :update, params: settings_params, xhr: true
        expect(response).to have_http_status(200)

        ip_whitelist.reload
        expect(ip_whitelist.value).to eq ['0.0.0.0', '192.168.255.0']
    end

    it 'updates country_source_whitelist' do

      login_as(:admin)

      settings_params = {
        data: {
            id: country_source_whitelist.id,
            attributes: {
              value: ["DE", "US"]
            }
        }, id: country_source_whitelist.id
      }
      patch :update, params: settings_params, xhr: true
      country_source_whitelist.reload

      expect(country_source_whitelist.value).to eq ["DE", "US"]
      expect(response).to have_http_status(200)
    end
    it 'is not possible for non-admin to update setting' do
      login_as(:alice)

      settings_params = {
        data: {
            id: ip_whitelist.id,
            attributes: {
              value: ['0.0.0.0', '192.168.255.0']
            }
          }, id: ip_whitelist.id
        }
        
        patch :update, params: settings_params, xhr: true
        expect(response).to have_http_status(403)

        ip_whitelist.reload
        expect(ip_whitelist.value).to eq ['0.0.0.0', '192.168.10.0']
    end

  end
end



