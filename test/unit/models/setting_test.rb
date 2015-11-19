require 'test_helper'
class SettingTest <  ActiveSupport::TestCase
  test 'returns boolean' do
    setting = Setting::TrueFalse.create(key: 'bla', value: 'f')
    setting.value = true
    assert setting.value.is_a?(TrueClass)
  end
end