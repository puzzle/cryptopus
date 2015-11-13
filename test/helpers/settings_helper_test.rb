require 'test_helper'

class SettingsHelperTest < ActionView::TestCase
  include Admin::SettingsHelper
  test 'create label and input for text' do
    result = input_field_setting(Setting.find_by(key: 'ldap_basename'))
    assert_match(/<label/, result)
    assert_match(/<input/, result)
    assert_match(/type="text"/, result)
  end

  test 'create label and input for number' do
    result = input_field_setting(Setting.find_by(key: 'ldap_portnumber'))
    assert_match(/<label/, result)
    assert_match(/<input/, result)
    assert_match(/type="number"/, result)
  end

  test 'create label and input for boolean' do
    result = input_field_setting(Setting.find_by(key: 'ldap_enable'))
    assert_match(/<label/, result)
    assert_match(/<input/, result)
    assert_match(/type="checkbox"/, result)
  end
end