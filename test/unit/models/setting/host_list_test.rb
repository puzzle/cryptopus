# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class HostListTest < ActiveSupport::TestCase
  test 'cannot create invalid host' do
    setting = Setting::HostList.new(value: ['?...$äöü'])
    assert_not setting.valid?
  end

  test 'does not create empty host' do
    setting = Setting::HostList.new(value: [' '])
    assert setting.valid?
    assert_equal [], setting.value
  end

  test 'creates valid host' do
    setting = Setting::HostList.new(value: ['1.1.1.1', 'ldap1.crypto.pus'])
    assert setting.valid?
  end
end
