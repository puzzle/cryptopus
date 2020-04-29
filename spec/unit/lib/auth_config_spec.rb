# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe AuthConfig do

  let(:auth) { AuthConfig.new }

  context '#ldap_settings' do
    it 'should return all ldap settings' do
      expect_any_instance_of(AuthConfig)
        .to receive(:settings_file)
        .and_return(settings_file('ldap_auth.yml.test'))
      settings = auth.ldap

      expect(settings[:portnumber]).to eq(636)
      expect(settings[:hostnames].length).to eq(2)
      expect(settings[:basename]).to eq('ou=users,dc=acme')
      expect(settings[:bind_password]).to eq('ZXhhbXBsZV9iaW5kX3Bhc3N3b3Jk')
      expect(settings[:encryption]).to eq('simple_tls')
      expect(settings.length).to eq(6)
    end
  end

  context '#ldap_enabled?' do
    it 'returns true for enabled ldap' do
      expect_any_instance_of(AuthConfig)
        .to receive(:settings_file)
        .and_return(settings_file('ldap_auth.yml.test'))
      expect(auth).to be_ldap_enabled
    end

    it 'returns false for empty authfile' do
      expect_any_instance_of(AuthConfig).to receive(:settings_file).and_return({})

      expect(auth).to_not be_ldap_enabled
    end
  end

  context '#provider' do
    it 'returns ldap as provider' do
      expect_any_instance_of(AuthConfig)
        .to receive(:settings_file)
        .and_return(settings_file('ldap_auth.yml.test'))

      expect(auth).to be_ldap_enabled
    end

    it 'returns db as provider with default file' do
      expect(AuthConfig.provider).to eq('db')
      expect(AuthConfig).to_not be_ldap_enabled
    end

    it 'returns keycloak as provider' do
      expect_any_instance_of(AuthConfig)
        .to receive(:settings_file)
        .twice
        .and_return(settings_file('keycloak_auth.yml.test'))

      expect(AuthConfig.provider).to eq('keycloak')
      expect(AuthConfig).to be_keycloak_enabled
    end
  end

  def settings_file(file)
    YAML.safe_load(File.read("spec/fixtures/files/auth/#{file}")).deep_symbolize_keys
  end
end
