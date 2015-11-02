require 'test_helper'
class UserTest < ActiveSupport::TestCase
  test 'cannot create second user bob' do
    user = User.new(username: 'bob')
    assert_not user.valid?
    assert_equal [:username], user.errors.keys
  end

  test 'creates user root' do
    User.delete_all
    User.create_root('pw')

    root = User.find_by_uid(0)
    assert_equal 'root', root.username
    assert_equal 'root', root.givenname
    assert_equal '', root.surname
    assert root.auth_db?
  end

  test 'does not create user root if it already exists' do
  end

  test 'returns user bob if authentication valid' do
    user = User.authenticate('bob', 'password')
    assert_equal users(:bob), user
  end

  test 'returns nil if invalid password' do
    user = User.authenticate('bob', 'wrong')
    assert_nil user
  end

  test 'returns nil if invalid user' do
    user = User.authenticate('fred', 'password')
    assert_nil user
  end

  test 'updates bobs user password' do
    bob = users(:bob)
    private_key = decrypt_private_key(bob, 'password')
    bob.update_password('password', 'new')

    assert_nil User.authenticate('bob', 'password')
    assert_equal bob, User.authenticate('bob', 'new')
    assert_equal private_key, decrypt_private_key(bob, 'new')
  end

  #test 'creates ldap user on first login' do
  #end

  private
  def decrypt_private_key(user, password)
    CryptUtils.decrypt_private_key(user.private_key, password)
  end
end
