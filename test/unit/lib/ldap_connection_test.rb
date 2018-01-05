# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LdapConnectionTest <  ActiveSupport::TestCase

  LdapConnection::MANDATORY_LDAP_SETTING_KEYS.each do |k|
    test "raises error on missing mandatory setting value: #{k}" do
      Setting.find_by(key: "ldap_#{k}").update!(value: nil)
      assert_raises ArgumentError do
        ldap_connection
      end
    end
  end

  test 'authenticates with valid user password' do
    user_entry = mock()
    user_entry.expects(:dn)
      .returns('uid=bob,ou=ldap')

    Net::LDAP.any_instance.expects(:bind_as)
      .with({base: 'example_basename', filter: "uid=#{'bob'}", password: 'pw'})
      .returns([user_entry])

    Net::LDAP.any_instance.expects(:bind)
      .times(2) # TODO make sure there is only 1 bind request in any case
      .returns(true)
    assert_equal true, ldap_connection.login('bob', 'pw')
  end

  test 'does not authenticate with valid user but invalid password' do
    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP.any_instance.expects(:bind_as)
      .with({base: 'example_basename', filter: "uid=#{'bob'}", password: 'invalid'})
      .returns(false)

    assert_equal false, ldap_connection.login('bob', 'invalid')
  end

  test 'does not authenticate if username contains invalid characters' do
    Net::LDAP.any_instance.expects(:bind_as).never

    assert_equal false, ldap_connection.login('bob$', 'pw')
  end

  test 'does not authenticate if username/password blank' do
    Net::LDAP.any_instance.expects(:bind_as).never

    assert_equal false, ldap_connection.login('', '')
  end

  test 'does not authenticate if user does not exist' do
    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP.any_instance.expects(:bind_as)
      .with({base: 'example_basename', filter: "uid=#{'mrunknown'}", password: 'pw'})
      .returns(false)

    assert_equal false, ldap_connection.login('mrunknown', 'pw')
  end

  test 'does not return info if uid does not exist' do
    filter = Net::LDAP::Filter.eq('uidnumber', 1)

    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP::Filter.expects(:eq)
      .with('uidnumber', '1')
      .returns(filter)

    Net::LDAP.any_instance.expects(:search)
      .with(base: 'example_basename', filter: filter)
      .returns(nil)

    assert_equal 'No uid for uidnumber 1', ldap_connection.ldap_info('1', 'uid')
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

  test 'does not return info if attribute does not exist' do
    filter = Net::LDAP::Filter.eq('uidnumber', 1)

    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP::Filter.expects(:eq)
      .with('uidnumber', '1')
      .returns(filter)

    entry = mock()
    entry.expects(:try)
      .with('unknown_attr')

    Net::LDAP.any_instance.expects(:search)
      .with(base: 'example_basename', filter: filter)
      .returns([entry])

    assert_equal 'No unknown_attr for uidnumber 1', ldap_connection.ldap_info('1', 'unknown_attr')
  end

  test 'returns ldap info' do
    filter = Net::LDAP::Filter.eq('uidnumber', 1)

    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP::Filter.expects(:eq)
      .with('uidnumber', '1')
      .returns(filter)

    entry = mock()
    entry.expects(:try)
      .with('uid')
      .returns(["bob"])

    Net::LDAP.any_instance.expects(:search)
      .with(base: 'example_basename', filter: filter)
      .returns([entry])

    assert_equal 'bob', ldap_connection.ldap_info('1', 'uid')
  end

  test 'does not return uidnumber if username invalid' do
    Net::LDAP.any_instance.expects(:search).never

    assert_nil ldap_connection.uidnumber_by_username('bob$')
  end

  test 'returns uidnumber by username' do
    filter = Net::LDAP::Filter.eq('uid', 'bob')

    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP::Filter.expects(:eq)
      .with('uid', 'bob')
      .returns(filter)

    entry = mock()
    entry.expects(:uidnumber)
      .returns([1])

    Net::LDAP.any_instance.expects(:search)
      .with(base: 'example_basename', filter: filter, attributes: ['uidnumber'])
      .yields(entry)

    assert_equal '1', ldap_connection.uidnumber_by_username('bob')
  end

  test 'does not return uidnumber if username not exists' do
    filter = Net::LDAP::Filter.eq('uid', 'unknownuser')

    Net::LDAP.any_instance.expects(:bind)
      .returns(true)

    Net::LDAP::Filter.expects(:eq)
      .with('uid', 'unknownuser')
      .returns(filter)

    Net::LDAP.any_instance.expects(:search)
      .with(base: 'example_basename', filter: filter, attributes: ['uidnumber'])
      .yields([])

    error = assert_raises { ldap_connection.uidnumber_by_username('unknownuser') }
    assert_equal 'No uidnumber for uid unknownuser', error.message
  end

  test 'reaches first ldap server' do
    connection = set_settings('ldap1.crypto.pus', 'ldap2.crypto.pus')

    user_entry = mock()
    user_entry.expects(:dn)
      .returns('uid=bob,ou=ldap')

    Net::LDAP.any_instance.expects(:bind_as)
      .with(base: "ou=ldap",
            filter: "uid=bob",
            password: "pw")
      .returns([user_entry])


    Net::LDAP.any_instance.expects(:bind)
      .times(2) # TODO make sure there is only 1 bind request in any case
      .returns(true)

    assert_equal true, connection.login('bob', 'pw')
  end

  test 'reaches second ldap server' do
    connection = set_settings('ldap1.crypto.pus', 'ldap2.crypto.pus')

    user_entry = mock()
    user_entry.expects(:dn)
      .returns('uid=bob,ou=ldap')

    Net::LDAP.any_instance.expects(:bind)
      .times(3) # TODO make sure there is only 1 bind request in any case
      .raises(Net::LDAP::Error)
      .then
      .returns(true)

    Net::LDAP.any_instance.expects(:bind_as)
      .with(base: "ou=ldap",
            filter: "uid=bob",
            password: "pw")
      .returns([user_entry])

    assert_equal true, connection.login('bob', 'pw')
  end

  test 'ldap server cannot be resolved by dns' do
    connection = set_settings('ldap1.crypto.pus', 'ldap2.crypto.pus')

    Net::LDAP.any_instance.expects(:bind)
     .times(2) # TODO make sure there is only 1 bind request in any case
     .raises(Net::LDAP::Error, 'getaddrinfo: Name or service not known')

     e = assert_raise Net::LDAP::Error do
       connection.login('bob', 'pw')
     end

     assert_match(/Name or service not known/, e.message)
  end

  test 'ldap server is not reachable' do
    connection = set_settings('ldap1.crypto.pus', 'ldap2.crypto.pus')

    Net::LDAP.any_instance.expects(:bind)
     .times(2)
     .raises(Net::LDAP::Error, 'Connection timed out - user specified timeout')

     e = assert_raise Net::LDAP::Error do
       connection.login('bob', 'pw')
     end

     assert_match(/Connection timed out/, e.message)
  end

  test 'ldap server refused connection' do
    connection = set_settings('ldap1.crypto.pus', 'ldap2.crypto.pus')

    Net::LDAP.any_instance.expects(:bind)
     .times(2)
     .raises(Net::LDAP::ConnectionRefusedError)

     assert_raise Net::LDAP::ConnectionRefusedError do
       connection.login('bob', 'pw')
     end
  end

  test 'unexpected error occured while trying to reach first ldap server' do
    connection = set_settings('ldap1.crypto.pus', 'ldap2.crypto.pus')

    Net::LDAP.any_instance.expects(:bind)
     .times(2) # TODO make sure there is only 1 bind request in any case
     .raises(Net::LDAP::Error, 'unauthenticated bind (DN with no password) disallowed')

     e = assert_raises Net::LDAP::Error do
      connection.login('bob', 'pw')
     end

     assert_match(/DN with no password/, e.message)
  end

  def set_settings(hostname1, hostname2)
    connection = ldap_connection
    connection.instance_variable_set('@settings', {hostname: [hostname1, hostname2],
                                                   basename: "ou=ldap",
                                                   portnumber: "666",
                                                   bind_dn: "example_bind_dn",
                                                   bind_password: "example_bind_password"})
    connection
  end

  def ldap_connection
    LdapConnection.new
  end

end
