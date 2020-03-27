# frozen_string_literal: true

require 'rails_helper'

describe Admin::SettingsController do
  include ControllerHelpers

  context 'POST update_all' do
    it 'updates setting attributes' do
      login_as(:admin)
      post :update_all, params: { setting: { general_country_source_whitelist: %w[CH UK],
                                             general_ip_whitelist: ['192.168.1.1',
                                                                    '192.168.1.2'] } }
      expect(Setting.value(:general, :country_source_whitelist)).to eq(%w[CH UK])
      expect(Setting.value(:general, :ip_whitelist)).to eq(['192.168.1.1', '192.168.1.2'])
      expect(flash[:notice]).to match(/successfully updated/)
    end

    it 'shows error if one setting is invalid' do
      login_as(:admin)

      post :update_all, params: { setting: { general_ip_whitelist: ['a.b.c.d/99'] } }

      expect(flash[:error]).to eq 'invalid ip address: a.b.c.d/99'
    end
  end
end
