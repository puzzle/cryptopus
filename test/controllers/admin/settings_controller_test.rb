# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::SettingsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'update setting attributes' do
    login_as(:admin)
    post :update_all, setting: {ldap_basename: 'test_basename', ldap_portnumber: '1234', ldap_enable: 'f'}
    assert_equal 'test_basename', Setting.value(:ldap, :basename)
    assert_equal '1234', Setting.value(:ldap, :portnumber)
    assert_not Setting.value(:ldap, :enable)
    assert_match /successfully updated/, flash[:notice]
  end

  test 'show error if one setting is invalid' do
    login_as(:admin)

    post :update_all, setting: {general_ip_whitelist: ['a.b.c.d/99']}

    assert_equal 'invalid ip address: a.b.c.d/99', flash[:error]
  end
end
