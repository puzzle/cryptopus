# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class SettingTest <  ActiveSupport::TestCase
  test 'returns boolean' do
    setting = Setting::TrueFalse.create(key: 'bla', value: 'f')
    setting.value = true
    assert setting.value.is_a?(TrueClass)
  end

  test 'store country codes without blank values' do
    setting = Setting.find_by(key: 'general_country_source_whitelist')
    setting.update(value: ['CH', 'US', ''])


    country_codes = setting.reload.value
    assert_equal 2, country_codes.count
    assert_equal 'CH', country_codes.first
    assert_equal 'US', country_codes.second
  end

  test 'does not persist invalid country code'  do
    setting = Setting.find_by(key: 'general_country_source_whitelist')
    setting.update(value: ['IT', 'ABC42'])

    assert_equal 1, setting.errors.count
    assert_equal 'invalid country code: ABC42', setting.errors[:value][0]

    country_codes = setting.reload.value
    assert_equal 1, country_codes.count
    assert_equal 'CH', country_codes.first
  end

  test 'returns ips without empty values' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    setting.update(value: ['123.20.123.23', '5.0.0.0/8', ''])

    assert_equal false, setting.errors.present?

    ips = setting.reload.value
    assert_equal 2, ips.count
    assert_equal '123.20.123.23', ips.first
    assert_equal '5.0.0.0/8', ips.second
  end

  test 'does not accept invalid ip' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    setting.update(value: ['123.20.123.23', 'a.b.c.d'])
  
    assert_equal 'invalid ip address: a.b.c.d', setting.errors[:value][0]
  end

  test 'does not add ips with invalid subnet' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    setting.update(value: ['10.0.0.1/300'])
  
    assert_equal 'invalid ip address: 10.0.0.1/300', setting.errors[:value][0]
  end

end
