# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
migration_file_name = Dir[Rails.root.join('db/migrate/20171010071016_multiple_ldap_hostnames.rb')].first
require migration_file_name

class MultipleLdapHostnamesMigrationTest < ActiveSupport::TestCase

  before(:each) do
    ldap_hostname_setting.destroy!
  end

  describe '#up' do
    test 'changes text to hostlist' do
      Setting.create!(key: 'ldap_hostname', value: 'ldap1.crypto.pus', type: 'Setting::Text')

      migration.up

      assert_equal 'Setting::HostList', ldap_hostname_setting.type
      assert_equal ['ldap1.crypto.pus'], ldap_hostname_setting.value
    end

    test 'changes empty text to hostlist' do
      Setting.create!(key: 'ldap_hostname', value: '', type: 'Setting::Text')

      migration.up

      assert_equal 'Setting::HostList', ldap_hostname_setting.type
      assert_equal [], ldap_hostname_setting.value
    end

    test 'changes text to hostlist even when no value exists' do
      Setting.create!(key: 'ldap_hostname', value: nil, type: 'Setting::Text')

      migration.up

      assert_equal 'Setting::HostList', ldap_hostname_setting.type
      assert_equal [], ldap_hostname_setting.value
    end
  end

  describe '#down' do
    test 'changes hostlist to text' do
      Setting.create!(key: 'ldap_hostname', value: ['ldap1.crypto.pus'], type: 'Setting::HostList')

      migration.down

      assert_equal 'Setting::Text', ldap_hostname_setting.type
      assert_equal 'ldap1.crypto.pus', ldap_hostname_setting.value
    end

    test 'changes empty hostlist to text' do
      Setting.create!(key: 'ldap_hostname', value: [], type: 'Setting::HostList')

      migration.down

      assert_equal 'Setting::Text', ldap_hostname_setting.type
      assert_nil ldap_hostname_setting.value
    end
  end

  private

  def migration
    MultipleLdapHostnames.new
  end

  def ldap_hostname_setting
    Setting.find_by(key: 'ldap_hostname')
  end

end
