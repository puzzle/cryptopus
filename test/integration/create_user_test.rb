require 'test_helper'
class CreateUserTest < ActionDispatch::IntegrationTest
=begin
  test 'root creates new user' do
    login_as('root', 'password')
    post "/admin/users", user: {
                                  username: "fgerber",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Fritz",
                                  surname: "Gerber"}
    assert_redirected_to '/admin/users'
    assert User.find_by_username('fgerber')
  end


  test 'cannot create second user bob' do
    login_as('root', 'password')
    post "/admin/users", user: {
                                  username: "bob",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Bob",
                                  surname: "Test"}
    #TODO Assertion for test
  end


  test 'bob cannot create new user' do
    login_as('bob', 'password')
    post "/admin/users", user: {
                                  username: "rsiegfried",
                                  password: "password",
                                  admin: 0,
                                  givenname: "Roland",
                                  surname: "Siegfried"}
    assert_redirected_to '/teams'
    assert_nil User.find_by_username('rsiegfried')
  end
=end
end
