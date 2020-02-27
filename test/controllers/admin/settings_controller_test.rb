# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::SettingsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  setup do
    GeoIp.stubs(:activated?)
  end

  test 'update setting attributes' do
    login_as(:admin)
    post :update_all, params: { setting: {general_country_source_whitelist: ['CH','UK'], general_ip_whitelist: ['192.168.1.1','192.168.1.2']} }
    assert_equal ['CH','UK'], Setting.value(:general, :country_source_whitelist)
    assert_equal ['192.168.1.1','192.168.1.2'], Setting.value(:general, :ip_whitelist)
    assert_match /successfully updated/, flash[:notice]
  end

  test 'show error if one setting is invalid' do
    login_as(:admin)

    post :update_all, params: { setting: {general_ip_whitelist: ['a.b.c.d/99']} }

    assert_equal 'invalid ip address: a.b.c.d/99', flash[:error]
  end
end
