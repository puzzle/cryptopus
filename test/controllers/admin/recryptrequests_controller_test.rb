# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::RecryptrequestsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  def setup
    request.env["HTTP_REFERER"] = 'where_i_came_from'
  end

  test 'error message if recrypt_team_password raises error' do
    CryptUtils.expects(:decrypt_team_password).raises('test')

    login_as(:admin)
    bob = users(:bob)

    post :resetpassword, new_password: 'test', user_id: bob.id

    assert_match /test/, flash[:error]
  end

  test 'reset bobs password' do
    login_as(:admin)
    bob = users(:bob)
    crypted_password = CryptUtils.one_way_crypt('test')

    post :resetpassword, new_password: 'test', user_id: bob.id

    bob.reload

    assert_equal crypted_password, bob.password
    assert_redirected_to 'where_i_came_from'
  end

  test 'does not reset password if blank password' do
    login_as(:admin)
    bob = users(:bob)
    bob_password = bob.password

    post :resetpassword, user_id: bob.id

    bob.reload

    assert_equal bob_password, bob.password
    assert_redirected_to 'where_i_came_from'
    assert_match /The password must not be blank/, flash[:notice]
  end

  test 'does not reset ldap users password' do
    login_as(:admin)
    bob = users(:bob)
    bob.update_attribute(:auth, 'ldap')
    bob_password = bob.password

    post :resetpassword, new_password: 'test', user_id: bob.id

    bob.reload

    assert_equal bob_password, bob.password
    assert_redirected_to 'where_i_came_from'
  end

  test 'normal user could not reset password' do
    login_as(:bob)
    alice = users(:alice)
    alice_password = alice.password

    post :resetpassword, new_password: 'test', user_id: alice.id

    alice.reload

    assert_equal alice_password, alice.password
  end

  test 'show recryptrequests' do
    login_as(:admin)
    get :index
  end
end
