# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

describe AuthConfig do

  describe '#ldap_settings' do
    it 'should return all ldap settings' do
      auth = AuthConfig.new('test/fixtures/files/auth/auth.yml.test')
      settings = auth.ldap

      assert_equal 636, settings[:portnumber]
      assert_equal 2, settings[:hostnames].length
      assert_equal 'ou=users,dc=acme', settings[:basename]
      assert_equal 'example_bind_password', settings[:bind_password]
      assert_equal :simple_tls, settings[:encryption]
      assert_equal 6, settings.length
    end

    it 'should throw exception about missing hostname' do
      auth = AuthConfig.new('test/fixtures/files/auth/no_host_auth.yml.test')

      error = assert_raises do
        auth.ldap
      end
      assert_equal 'missing config field: hostnames', error.message
    end

    it 'should throw exception for no ldap settings' do
      auth = AuthConfig.new('test/fixtures/files/auth/empty_auth.yml.test')

      error = assert_raises do
        auth.ldap
      end
      assert_equal 'No ldap settings', error.message
    end
  end

  describe '#ldap_enabled?' do
    it 'returns true for enabled ldap' do
      auth = AuthConfig.new('test/fixtures/files/auth/auth.yml.test')
      assert_equal true, auth.ldap_enabled?
    end

    it 'returns false for empty authfile' do
      auth = AuthConfig.new('test/fixtures/files/auth/empty_auth.yml.test')

      assert_equal false, auth.ldap_enabled?
    end
  end

  describe '#provider' do
    it 'returns ldap as provider' do
      auth = AuthConfig.new('test/fixtures/files/auth/auth.yml.test')

      assert_equal 'ldap', auth.provider
      assert_equal true, auth.ldap_enabled?
    end

    it 'returns db as provider with no file' do
      auth = AuthConfig.new('test/fixtures/files/auth/no_file_auth.yml.test')

      assert_equal 'db', auth.provider
      assert_equal false, auth.ldap_enabled?
    end
  end
end
