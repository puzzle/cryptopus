# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LdapConnectionTest < ActiveSupport::TestCase

  context 'ldap settings' do

    LdapConnection::MANDATORY_LDAP_SETTING_KEYS.each do |k|
      test "raises error on missing mandatory setting value: #{k}" do
        Setting.find_by(key: "ldap_#{k}").update!(value: nil)
        assert_raises ArgumentError do
          ldap_connection
        end
      end
    end

  end

  context '#authenticate' do

    test 'authenticates with valid user and password' do
      user_entry = mock
      user_entry.expects(:dn)
                .returns('uid=bob,ou=ldap')

      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
               .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test, once as user dn
      Net::LDAP.any_instance.expects(:bind)
               .times(2)
               .returns(true)

      # search for user_dn
      search_filter = Net::LDAP::Filter.eq('uid', 'bob')
      Net::LDAP.any_instance.expects(:search)
               .with(base: 'ou=users,dc=acme', filter: search_filter)
               .yields(user_entry)

      # authenticate with user dn and user password
      Net::LDAP.any_instance.expects(:auth)
               .with('uid=bob,ou=ldap', 'pw')

      assert_equal true, ldap_connection.authenticate!('bob', 'pw')
    end

    test 'does not authenticate with valid user but invalid password' do
      user_entry = mock
      user_entry.expects(:dn)
                .returns('uid=bob,ou=ldap')

      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
               .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test, once as user dn
      Net::LDAP.any_instance.expects(:bind)
               .times(2)
               .returns(true)
               .then
               .returns(false)

      # search for user_dn
      search_filter = Net::LDAP::Filter.eq('uid', 'bob')
      Net::LDAP.any_instance.expects(:search)
               .with(base: 'ou=users,dc=acme', filter: search_filter)
               .yields(user_entry)

      # authenticate with user dn and user password
      Net::LDAP.any_instance.expects(:auth)
               .with('uid=bob,ou=ldap', 'wrong-pw')

      assert_equal false, ldap_connection.authenticate!('bob', 'wrong-pw')
    end

    test 'does not authenticate if user does not exist' do
      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
               .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      Net::LDAP.any_instance.expects(:bind)
               .returns(true)

      # search for user_dn
      search_filter = Net::LDAP::Filter.eq('uid', 'ghost')
      Net::LDAP.any_instance.expects(:search)
               .with(base: 'ou=users,dc=acme', filter: search_filter)
               .yields(nil)

      # never authenticate with user dn and user password
      Net::LDAP.any_instance.expects(:auth)
        .never

      assert_equal false, ldap_connection.authenticate!('ghost', 'pw')
    end

  end

  context '#ldap_info' do

    test 'does not return info if uid does not exist' do
      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      Net::LDAP.any_instance.expects(:bind)
        .returns(true)

      filter = Net::LDAP::Filter.eq('uidnumber', 1)

      Net::LDAP::Filter.expects(:eq)
        .with('uidnumber', '1')
        .returns(filter)

      Net::LDAP.any_instance.expects(:search)
        .with(base: 'ou=users,dc=acme', filter: filter)
        .returns(nil)

      assert_equal 'No uid for uidnumber 1', ldap_connection.ldap_info('1', 'uid')
    end

    test 'does not return info if attribute does not exist' do
      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      Net::LDAP.any_instance.expects(:bind)
        .returns(true)

      filter = Net::LDAP::Filter.eq('uidnumber', 1)

      Net::LDAP::Filter.expects(:eq)
        .with('uidnumber', '1')
        .returns(filter)

      entry = mock()
      entry.expects(:try)
        .with('unknown_attr')

      Net::LDAP.any_instance.expects(:search)
        .with(base: 'ou=users,dc=acme', filter: filter)
        .returns([entry])

      assert_equal 'No unknown_attr for uidnumber 1', ldap_connection.ldap_info('1', 'unknown_attr')
    end

    test 'raises exception if missing parameter' do
      assert_raises ArgumentError do
        ldap_connection.ldap_info(nil, nil)
      end
      assert_raises ArgumentError do
        ldap_connection.ldap_info('uidnumber', nil)
      end
      assert_raises ArgumentError do
        ldap_connection.ldap_info(nil, '1')
      end
    end

    test 'returns ldap info' do
      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      Net::LDAP.any_instance.expects(:bind)
        .returns(true)

      filter = Net::LDAP::Filter.eq('uidnumber', 1)

      Net::LDAP::Filter.expects(:eq)
        .with('uidnumber', '1')
        .returns(filter)

      entry = mock()
      entry.expects(:try)
        .with('uid')
        .returns(["bob"])

      Net::LDAP.any_instance.expects(:search)
        .with(base: 'ou=users,dc=acme', filter: filter)
        .returns([entry])

      assert_equal 'bob', ldap_connection.ldap_info('1', 'uid')
    end

    test 'does not return uidnumber if username invalid' do
      Net::LDAP.any_instance.expects(:bind).never
      Net::LDAP.any_instance.expects(:auth).never
      Net::LDAP.any_instance.expects(:search).never

      assert_nil ldap_connection.uidnumber_by_username('bob$')
    end

    test 'returns uidnumber by username' do
      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      Net::LDAP.any_instance.expects(:bind)
        .returns(true)

      filter = Net::LDAP::Filter.eq('uid', 'bob')

      Net::LDAP::Filter.expects(:eq)
        .with('uid', 'bob')
        .returns(filter)

      entry = mock()
      entry.expects(:uidnumber)
        .returns([1])

      Net::LDAP.any_instance.expects(:search)
        .with(base: 'ou=users,dc=acme', filter: filter, attributes: ['uidnumber'])
        .yields(entry)

      assert_equal '1', ldap_connection.uidnumber_by_username('bob')
    end

    test 'does not return uidnumber if username does not exist' do
      # bind by bind_dn
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      Net::LDAP.any_instance.expects(:bind)
        .returns(true)

      filter = Net::LDAP::Filter.eq('uid', 'unknownuser')

      Net::LDAP::Filter.expects(:eq)
        .with('uid', 'unknownuser')
        .returns(filter)

      Net::LDAP.any_instance.expects(:search)
        .with(base: 'ou=users,dc=acme', filter: filter, attributes: ['uidnumber'])
        .yields([])

      error = assert_raises { ldap_connection.uidnumber_by_username('unknownuser') }
      assert_equal 'No uidnumber for uid unknownuser', error.message
    end

  end

  context "multiple ldap servers" do

    test 'reaches first ldap server' do
      settings(:ldap_hostname).update!(value: ['ldap1.crypto.pus', 'ldap2.crypto.pus'])

      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      Net::LDAP.any_instance.expects(:bind)
        .returns(true)

      assert_equal 'ldap1.crypto.pus', ldap_connection.send(:connection).host
    end

    test 'reaches second ldap server' do
      settings(:ldap_hostname).update!(value: ['ldap1.crypto.pus', 'ldap2.crypto.pus'])

      Net::LDAP.any_instance.expects(:bind)
        .times(2)
        .raises(Net::LDAP::Error, 'connection timed out')
        .then
        .returns(true)

      Net::LDAP.any_instance.expects(:auth)
        .times(2)
        .with('example_bind_dn', 'example_bind_password')

      assert_equal 'ldap2.crypto.pus', ldap_connection.send(:connection).host
    end

    test 'ldap server cannot be resolved by dns' do
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      Net::LDAP.any_instance.expects(:bind)
        .raises(Net::LDAP::Error, 'getaddrinfo: Name or service not known')

      e = assert_raise Net::LDAP::Error do
        ldap_connection.send(:connection)
      end

      assert_match(/Name or service not known/, e.message)
    end

    test 'ldap server is not reachable' do
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      Net::LDAP.any_instance.expects(:bind)
        .raises(Net::LDAP::Error, 'Connection timed out - user specified timeout')

      e = assert_raise Net::LDAP::Error do
        ldap_connection.send(:connection)
      end

      assert_match(/Connection timed out/, e.message)
    end

    test 'ldap server refuses connection' do
      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      Net::LDAP.any_instance.expects(:bind)
        .raises(Net::LDAP::ConnectionRefusedError)

      assert_raise Net::LDAP::ConnectionRefusedError do
        ldap_connection.send(:connection)
      end
    end

    test 'unexpected error occured while trying to reach first ldap server' do
      settings(:ldap_hostname).update!(value: ['ldap1.crypto.pus', 'ldap2.crypto.pus'])

      Net::LDAP.any_instance.expects(:auth)
        .with('example_bind_dn', 'example_bind_password')

      Net::LDAP.any_instance.expects(:bind)
        .raises(Net::LDAP::Error, 'unauthenticated bind (DN with no password) disallowed')

      e = assert_raises Net::LDAP::Error do
        ldap_connection.send(:connection)
      end

      assert_match(/DN with no password/, e.message)
    end

  end

  def ldap_connection
    LdapConnection.new
  end

end
