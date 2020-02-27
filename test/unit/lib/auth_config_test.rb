# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

describe AuthConfig do

  describe '#ldap_settings' do
    it 'should return all ldap settings' do
      AuthConfig.any_instance.expects(:settings_file).returns(settings_file('auth.yml.test'))
      settings = auth.ldap

      assert_equal 636, settings[:portnumber]
      assert_equal 2, settings[:hostnames].length
      assert_equal 'ou=users,dc=acme', settings[:basename]
      assert_equal 'ZXhhbXBsZV9iaW5kX3Bhc3N3b3Jk', settings[:bind_password]
      assert_equal 'simple_tls', settings[:encryption]
      assert_equal 6, settings.length
    end
  end

  describe '#ldap_enabled?' do
    it 'returns true for enabled ldap' do
      AuthConfig.any_instance.expects(:settings_file).returns(settings_file('auth.yml.test'))
      assert_equal true, auth.ldap_enabled?
    end

    it 'returns false for empty authfile' do
      AuthConfig.any_instance.expects(:settings_file).returns({})

      assert_equal false, auth.ldap_enabled?
    end
  end

  describe '#provider' do
    it 'returns ldap as provider' do
      AuthConfig.any_instance.expects(:settings_file)
      .returns(settings_file('auth.yml.test'))
      .at_least_once

      assert_equal 'ldap', auth.provider
      assert_equal true, auth.ldap_enabled?
    end

    it 'returns db as provider with default file' do
      assert_equal 'db', AuthConfig.provider
      assert_equal false, AuthConfig.ldap_enabled?
    end
  end

  def auth
    AuthConfig.new
  end

  def settings_file(file)
    YAML.safe_load(File.read("test/fixtures/files/auth/#{file}")).deep_symbolize_keys
  end
end
