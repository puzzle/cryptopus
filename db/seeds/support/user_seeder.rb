# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class UserSeeder

  def seed_root
    User::Human.seed_once(:username) do |u|
      u.ldap_uid = 0
      u.username = 'root'
      u.givenname = 'root'
      u.auth = 'db'
      u.role = :admin
      u.password = CryptUtils.one_way_crypt('password')
      create_keypair(u)
    end
  end

  def seed_users(usernames, role = :user)
    usernames.each do |username|
      seed_user(username, role)
    end
  end

  def seed_conf_admins(usernames)
    seed_users(usernames, :conf_admin)
  end

  def seed_admins(usernames)
    seed_users(usernames, :admin)
  end

  private
  def seed_user(username, role = :user)
    User::Human.seed_once(:username) do |u|
      u.username = username.to_s
      u.givenname = username.to_s.capitalize
      u.surname = Faker::Name.last_name
      u.auth = 'db'
      u.password = CryptUtils.one_way_crypt('password')
      u.role = role
      create_keypair(u)
    end
  end

  def create_keypair(user)
    keypair = CryptUtils.new_keypair
    unencrypted_private_key = CryptUtils.extract_private_key(keypair)
    user.public_key = CryptUtils.extract_public_key(keypair)
    user.private_key = CryptUtils.encrypt_private_key(unencrypted_private_key, 'password')
  end

end
