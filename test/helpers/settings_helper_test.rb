# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class SettingsHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Admin::SettingsHelper
  test 'create label and input for text' do
    setting = Setting.find_by(key: 'ldap_basename')
    result = input_field_setting(setting)

    assert_match /<label/, result
    assert_match /<input/, result
    assert_match /type="text"/, result
    assert_match /name="setting\[ldap_basename\]"/, result
    assert_match /value="#{setting.value}"/, result
  end

  test 'create label and input for number' do
    setting = Setting.find_by(key: 'ldap_portnumber')
    result = input_field_setting(setting)

    assert_match /<label/, result
    assert_match /<input/, result
    assert_match /type="number"/, result
    assert_match /name="setting\[ldap_portnumber\]"/, result
    assert_match /value="#{setting.value}"/, result
  end

  test 'create label and input for boolean' do
    setting = Setting::TrueFalse.create(key: 'ldap_enable', value: 't')
    result = input_field_setting(setting)

    assert_match /<label/, result
    assert_match /<input/, result
    assert_match /type="checkbox"/, result
    assert_match /name="setting\[ldap_enable\]"/, result
    assert_match /checked="checked"/, result
    assert_match /value="t"/, result
    assert_match /value="f"/, result
  end
end
