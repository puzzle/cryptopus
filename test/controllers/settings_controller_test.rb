require 'test_helper'
require 'test/unit'

class Admin::SettingsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'update setting attributes' do
    login_as(:root)
    post :update_all, setting: {ldap_basename: 'test_basename', ldap_portnumber: '1234', ldap_enable: 'f'}
    assert_equal 'test_basename', Setting.find_ldap('basename').value
    assert_equal '1234', Setting.find_ldap('portnumber').value
    assert_not Setting.find_ldap('enable').value
    assert_match /successfully updated/, flash[:notice]
  end
end