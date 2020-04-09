# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Setting do
  it 'returns boolean' do
    setting = Setting::TrueFalse.create(key: 'bla', value: 'f')
    setting.value = true
    expect(setting.value.is_a?(TrueClass)).to eq(true)
  end

  it 'stores country codes without blank values' do
    setting = Setting.find_by(key: 'general_country_source_whitelist')
    setting.update(value: ['CH', 'US', ''])


    country_codes = setting.reload.value
    expect(country_codes.count).to eq(2)
    expect(country_codes.first).to eq('CH')
    expect(country_codes.second).to eq('US')
  end

  it 'does not persist invalid country code' do
    setting = Setting.find_by(key: 'general_country_source_whitelist')
    setting.update(value: %w[IT ABC42])

    expect(setting.errors.count).to eq(1)
    expect(setting.errors[:value][0]).to eq('invalid country code: ABC42')

    country_codes = setting.reload.value
    expect(country_codes.count).to eq(1)
    expect(country_codes.first).to eq('CH')
  end

  it 'returns ips without empty values' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    setting.update(value: ['123.20.123.23', '5.0.0.0/8', ''])

    expect(setting.errors.present?).to eq(false)

    ips = setting.reload.value
    expect(ips.count).to eq(2)
    expect(ips.first).to eq('123.20.123.23')
    expect(ips.second).to eq('5.0.0.0/8')
  end

  it 'does not accept invalid ip' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    setting.update(value: ['123.20.123.23', 'a.b.c.d'])

    expect(setting.errors[:value][0]).to eq('invalid ip address: a.b.c.d')
  end

  it 'does not add ips with invalid subnet' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    setting.update(value: ['10.0.0.1/300'])

    expect(setting.errors[:value][0]).to eq('invalid ip address: 10.0.0.1/300')
  end
end
