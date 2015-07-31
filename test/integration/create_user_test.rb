require 'test_helper'
class CreateUserTest < ActionDispatch::IntegrationTest

  test 'root creates new user' do
    login_as('root')
    post admin_users_path, user: {
                                  username: "fgerber",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Fritz",
                                  surname: "Gerber"}
    assert_redirected_to admin_users_path
    assert User.find_by_username('fgerber')
    logout
    login_as('fgerber')
  end

  test 'admin creates new user' do
    login_as('admin')
    post admin_users_path, user: {
                                  username: "skern",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Simon",
                                  surname: "Kern"}
    assert_redirected_to admin_users_path
    assert User.find_by_username('skern')
    logout
    login_as('skern')
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

=begin
    test 'cannot create second user bob' do
      login_as('root')
      post admin_users_path, user: {
                                    username: "bob",
                                    password: "password",
                                    admin: 0,
                                    givenname: "Bob",
                                    surname: "Test"}
      #TODO Assertion for test
    end
=end
end
