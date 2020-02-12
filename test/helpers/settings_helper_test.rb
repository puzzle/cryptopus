# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class SettingsHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Admin::SettingsHelper

  setup do
    GeoIp.stubs(:activated?)
  end

  test 'create label and input for text' do
    setting = Setting.find_by(key: 'general_ip_whitelist')
    result = input_field_setting(setting)
    assert_match /This would be the range between 12.0.0.0 and 12.255.255.255/, result
    assert_match /<input/, result
    assert_match 'name="setting[general_ip_whitelist][]"', result
    assert_match /value="#{setting.value[0]}"/, result
  end
end
