# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class CreateUserTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper

  test 'admin creates new user' do
    login_as('admin')
    post admin_users_path, params: { user: {
                                  username: "simon",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Simon",
                                  surname: "Kern"} }
    assert_redirected_to admin_users_path
    assert User.find_by_username('simon')
    logout
    login_as('simon')
  end

  test 'bob cannot create new user' do
    login_as('bob')
    post admin_users_path, params: { user: {
                                  username: "rsiegfried",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Roland",
                                  surname: "Siegfried"} }
    assert_redirected_to teams_path
    assert_nil User.find_by_username('rsiegfried')
  end

    test 'cannot create second user bob' do
      login_as('admin')
      post admin_users_path, params: { user: {
                                    username: "bob",
                                    password: "password",
                                    admin: 0,
                                    givenname: "Bob",
                                    surname: "Test"} }
      assert_equal request.fullpath, admin_users_path
      assert_includes response.body, 'Username has already been taken'
    end
end
