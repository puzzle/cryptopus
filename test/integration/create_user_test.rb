require 'test_helper'
class CreateUserTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'root creates new user' do
    login_as('root')
    post admin_users_path, user: {
                                  username: "fritz",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Fritz",
                                  surname: "Gerber"}
    assert_redirected_to admin_users_path
    assert User.find_by_username('fritz')
    logout
    login_as('fritz')
  end

  test 'admin creates new user' do
    login_as('admin')
    post admin_users_path, user: {
                                  username: "simon",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Simon",
                                  surname: "Kern"}
    assert_redirected_to admin_users_path
    assert User.find_by_username('simon')
    logout
    login_as('simon')
  end

  test 'bob cannot create new user' do
    login_as('bob')
    post admin_users_path, user: {
                                  username: "rsiegfried",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Roland",
                                  surname: "Siegfried"}
    assert_redirected_to teams_path
    assert_nil User.find_by_username('rsiegfried')
  end

    test 'cannot create second user bob' do
      login_as('root')
      post admin_users_path, user: {
                                    username: "bob",
                                    password: "password",
                                    admin: 0,
                                    givenname: "Bob",
                                    surname: "Test"}
      assert_equal request.fullpath, admin_users_path
      assert_includes response.body, 'Username has already been taken'
    end
end
