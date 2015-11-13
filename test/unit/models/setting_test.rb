require 'test_helper'
class SettingTest <  ActiveSupport::TestCase
  test 'return bollean @setting.value' do
    setting = Setting.find_by(key: 'ldap_enable')
    setting.value = 't'
    assert setting.value
  end
end