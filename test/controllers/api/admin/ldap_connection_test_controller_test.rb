# encoding: utf-8

# Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# Cryptopus and licensed under the Affero General Public License version 3 or later.
# See the COPYING file at the top-level directory or at
# https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Admin::LdapConnectionTestControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'connection to ldap server success' do
    login_as(:admin)
    enable_ldap

    Setting.find_by(key: 'ldap_enable').expects(:value).returns(true)

    Net::LDAP.any_instance.expects(:bind).returns(true)
    get :new

    info = JSON.parse(response.body)['messages']['info']

    assert_includes(info, 'Connection to Ldap Server example_hostname successful')
  end

  test 'connection to ldap server fails' do
    login_as(:admin)
    enable_ldap

    Setting.find_by(key: 'ldap_enable').expects(:value).returns(true)

    Net::LDAP.any_instance.expects(:bind).returns(false)
    get :new

    errors = JSON.parse(response.body)['messages']['errors']

    assert_includes(errors, 'Connection to Ldap Server example_hostname failed')
  end

  test 'no hostname is present' do
    login_as(:admin)
    enable_ldap

    Setting.find_by(key: 'ldap_enable').expects(:value).returns(true)

    Api::Admin::LdapConnectionTestController.any_instance.expects(:hostlist)
           .returns([])

    get :new

    errors = JSON.parse(response.body)['messages']['errors']

    assert_includes(errors, 'No hostname present')
  end

  test 'ldap disabled' do
    login_as(:admin)
    disable_ldap

    get :new
  end

  private

  def enable_ldap
    ldap = Setting.find_by(key: 'ldap_enable')
    ldap.update(value: true)
  end

  def disable_ldap
    ldap = Setting.find_by(key: 'ldap_enable')
    ldap.update(value: false)
  end
end
