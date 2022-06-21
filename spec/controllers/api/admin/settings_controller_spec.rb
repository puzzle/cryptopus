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

      first_attributes = data.first['attributes']
      expect(first_attributes['value']).to eq ['CH', 'DE']

      second_attributes = data.second['attributes']
      expect(second_attributes['value']).to eq ['0.0.0.0', '192.168.10.0']

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
            value: %w[DE US]
          }
        }, id: country_source_whitelist.id
      }
      patch :update, params: settings_params, xhr: true
      country_source_whitelist.reload

      expect(country_source_whitelist.value).to eq %w[DE US]
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

  context 'validate setting' do
    it 'is not possible to update setting when ip is invalid' do
      login_as(:admin)

      settings_params = {
        data: {
          id: ip_whitelist.id,
          attributes: {
            value: ['0.0.0.0', '192.168.265.0']
          }
        }, id: ip_whitelist.id
      }

      patch :update, params: settings_params, xhr: true
      expect(response).to have_http_status(422)

      ip_whitelist.reload
      expect(ip_whitelist.value).to eq ['0.0.0.0', '192.168.10.0']
    end

    it 'is not possible to update setting when country is invalid' do
      login_as(:admin)

      settings_params = {
        data: {
          id: country_source_whitelist.id,
          attributes: {
            value: %w[DEE US]
          }
        }, id: country_source_whitelist.id
      }

      patch :update, params: settings_params, xhr: true
      expect(response).to have_http_status(422)

      country_source_whitelist.reload
      expect(country_source_whitelist.value).to eq %w[CH DE]
    end
  end
end
