# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe LdapConnection do

  let(:ldap_connection) { LdapConnection.new }

  context '#ldap_settings' do
    it 'should throw exception for no ldap settings' do
      expect do
        ldap_connection
      end.to raise_error('No ldap settings')
    end

    it 'should throw exception about missing hostname' do
      expect(AuthConfig).to receive(:ldap_settings)
        .and_return(basename: 'ou=users,dc=acme', portnumber: 636)

      expect do
        ldap_connection
      end.to raise_error('missing config field: hostnames')
    end
  end

  context '#authenticate' do
    it 'authenticates with valid user and password' do
      enable_ldap
      user_entry = double
      expect(user_entry).to receive(:dn).and_return('uid=bob,ou=ldap')

      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth).with('example_bind_dn',
                                                               'example_bind_password')

      # once as bind dn for connection test, once as user dn
      expect_any_instance_of(Net::LDAP).to receive(:bind).exactly(2).times.and_return(true)

      # search for user_dn
      search_filter = Net::LDAP::Filter.eq('uid', 'bob')
      expect_any_instance_of(Net::LDAP).to receive(:search).with(base: 'ou=users,dc=acme',
                                                                 filter: search_filter)
                                                           .and_yield(user_entry)


      # authenticate with user dn and user password
      expect_any_instance_of(Net::LDAP).to receive(:auth).with('uid=bob,ou=ldap', 'pw')

      expect(ldap_connection.authenticate!('bob', 'pw')).to eq(true)
    end

    it 'does not authenticate with valid user but invalid password' do
      enable_ldap
      user_entry = double
      expect(user_entry).to receive(:dn)
        .and_return('uid=bob,ou=ldap')

      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test, once as user dn
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .exactly(2).times
        .and_return(true, false)

      # search for user_dn
      search_filter = Net::LDAP::Filter.eq('uid', 'bob')
      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: search_filter)
        .and_yield(user_entry)

      # authenticate with user dn and user password
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('uid=bob,ou=ldap', 'wrong-pw')

      expect(ldap_connection.authenticate!('bob', 'wrong-pw')).to eq(false)
    end

    it 'does not authenticate if user does not exist' do
      enable_ldap
      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      # search for user_dn
      search_filter = Net::LDAP::Filter.eq('uid', 'ghost')
      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: search_filter)
        .and_yield(nil)

      # never authenticate with user dn and user password
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .never

      expect(ldap_connection.authenticate!('ghost', 'pw')).to eq(false)
    end

  end

  context '#ldap_info' do

    it 'does not return info if uid does not exist' do
      enable_ldap
      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      filter = Net::LDAP::Filter.eq('uidnumber', 1)

      expect(Net::LDAP::Filter).to receive(:eq)
        .with('uidnumber', '1')
        .and_return(filter)

      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: filter)
        .and_return(nil)

      expect(ldap_connection.ldap_info('1', 'uid')).to eq('No uid for uidnumber 1')
    end

    it 'does not return info if attribute does not exist' do
      enable_ldap
      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      filter = Net::LDAP::Filter.eq('uidnumber', 1)

      expect(Net::LDAP::Filter).to receive(:eq)
        .with('uidnumber', '1')
        .and_return(filter)

      entry = double
      expect(entry).to receive(:try)
        .with('unknown_attr')

      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: filter)
        .and_return([entry])

      expect(ldap_connection.ldap_info('1',
                                       'unknown_attr')).to eq('No unknown_attr for uidnumber 1')
    end

    it 'raises exception if missing parameter' do
      enable_ldap
      expect do
        ldap_connection.ldap_info(nil, nil)
      end.to raise_error(ArgumentError)
      expect do
        ldap_connection.ldap_info('uidnumber', nil)
      end.to raise_error(ArgumentError)
      expect do
        ldap_connection.ldap_info(nil, '1')
      end.to raise_error(ArgumentError)
    end

    it 'returns ldap info' do
      enable_ldap
      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      filter = Net::LDAP::Filter.eq('uidnumber', 1)

      expect(Net::LDAP::Filter).to receive(:eq)
        .with('uidnumber', '1')
        .and_return(filter)

      entry = double
      expect(entry).to receive(:try)
        .with('uid')
        .and_return(['bob'])

      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: filter)
        .and_return([entry])

      expect(ldap_connection.ldap_info('1', 'uid')).to eq('bob')
    end

    it 'does not return uidnumber if username invalid' do
      enable_ldap
      expect_any_instance_of(Net::LDAP).to receive(:bind).never
      expect_any_instance_of(Net::LDAP).to receive(:auth).never
      expect_any_instance_of(Net::LDAP).to receive(:search).never

      expect(ldap_connection.uidnumber_by_username('bob$')).to be_nil
    end

    it 'returns uidnumber by username' do
      enable_ldap
      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      filter = Net::LDAP::Filter.eq('uid', 'bob')

      expect(Net::LDAP::Filter).to receive(:eq)
        .with('uid', 'bob')
        .and_return(filter)

      entry = double
      expect(entry).to receive(:uidnumber)
        .and_return([1])

      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: filter, attributes: ['uidnumber'])
        .and_yield(entry)

      expect(ldap_connection.uidnumber_by_username('bob')).to eq('1')
    end

    it 'does not return uidnumber if username does not exist' do
      enable_ldap
      # bind by bind_dn
      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      # once as bind dn for connection test
      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      filter = Net::LDAP::Filter.eq('uid', 'unknownuser')

      expect(Net::LDAP::Filter).to receive(:eq)
        .with('uid', 'unknownuser')
        .and_return(filter)

      expect_any_instance_of(Net::LDAP).to receive(:search)
        .with(base: 'ou=users,dc=acme', filter: filter, attributes: ['uidnumber'])
        .and_yield([])

      expect do
        ldap_connection.uidnumber_by_username('unknownuser')
      end.to raise_error('No uidnumber for uid unknownuser')
    end
  end

  context 'multiple ldap servers' do

    it 'reaches first ldap server' do
      enable_ldap
      expect_any_instance_of(LdapConnection)
        .to receive(:ldap_hosts)
        .at_least(:once)
        .and_return(['ldap1.crypto.pus', 'ldap2.crypto.pus'])

      expect_any_instance_of(Net::LDAP).to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')

      expect_any_instance_of(Net::LDAP).to receive(:bind)
        .and_return(true)

      expect(ldap_connection.send(:connection).host).to eq('ldap1.crypto.pus')
    end

    it 'reaches second ldap server' do
      enable_ldap
      ldap1 = double
      ldap2 = double
      expect(ldap2).to receive(:host).and_return('ldap2.crypto.pus')

      expect_any_instance_of(LdapConnection)
        .to receive(:ldap_hosts)
        .at_least(:once)
        .and_return(['ldap1.crypto.pus', 'ldap2.crypto.pus'])

      expect(Net::LDAP)
        .to receive(:new)
        .with(hash_including(host: 'ldap1.crypto.pus'))
        .and_return(ldap1)
      expect(Net::LDAP)
        .to receive(:new)
        .with(hash_including(host: 'ldap2.crypto.pus'))
        .and_return(ldap2)

      expect(ldap1).to receive(:auth)
      expect(ldap2).to receive(:auth)

      expect(ldap1).to receive(:bind).and_raise(Net::LDAP::Error, 'connection timed out')
      expect(ldap2).to receive(:bind).and_return(true)

      expect(ldap_connection.send(:connection).host).to eq('ldap2.crypto.pus')
    end

    it 'cannot resolve ldap server by dns' do
      enable_ldap
      expect_any_instance_of(Net::LDAP)
        .to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')
        .at_least(:once)

      expect_any_instance_of(Net::LDAP)
        .to receive(:bind)
        .at_least(:once)
        .and_raise(Net::LDAP::Error, 'getaddrinfo: Name or service not known')

      expect do
        ldap_connection.send(:connection)
      end.to raise_error(Net::LDAP::Error, /Name or service not known/)
    end

    it 'cannot reach ldap server' do
      enable_ldap
      expect_any_instance_of(Net::LDAP)
        .to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')
        .at_least(:once)

      expect_any_instance_of(Net::LDAP)
        .to receive(:bind)
        .at_least(:once)
        .and_raise(Net::LDAP::Error, 'Connection timed out - user specified timeout')

      expect do
        ldap_connection.send(:connection)
      end.to raise_error(Net::LDAP::Error, /Connection timed out/)
    end

    it 'gets connection refused by ldap server' do
      enable_ldap
      expect_any_instance_of(Net::LDAP)
        .to receive(:auth)
        .with('example_bind_dn', 'example_bind_password')
        .at_least(:once)

      expect_any_instance_of(Net::LDAP)
        .to receive(:bind)
        .and_raise(Errno::ECONNREFUSED)

      expect do
        ldap_connection.send(:connection)
      end.to raise_error(Errno::ECONNREFUSED)
    end

    it 'raises unexpected error while trying to reach first ldap server' do
      enable_ldap
      expect_any_instance_of(Net::LDAP).to receive(:auth).with('example_bind_dn',
                                                               'example_bind_password')

      expect_any_instance_of(Net::LDAP)
        .to receive(:bind)
        .and_raise(Net::LDAP::Error, 'unauthenticated bind (DN with no password) disallowed')

      expect do
        ldap_connection.send(:connection)
      end.to raise_error(Net::LDAP::Error, /DN with no password/)
    end

  end
end
