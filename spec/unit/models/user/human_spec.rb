# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe User::Human do

  let(:bob) { users(:bob) }
  let(:root) { users(:root) }
  let(:alice) { users(:alice) }
  let(:conf_admin) { users(:conf_admin) }

  context 'create' do
    it 'does not create user without name' do
      user = User::Human.new(username: '')
      expect(user).to_not be_valid
      expect(user.errors.keys).to eq([:username])
    end

    it 'does not create second user bob' do
      user = User::Human.new(username: 'bob')
      expect(user).to_not be_valid
      expect(user.errors.keys).to eq([:username])
    end

  end

  context 'update_password' do
    it 'updates bobs user password' do
      decrypted_private_key = bob.decrypt_private_key('password')
      bob.update_password('password', 'new')

      expect(Authentication::UserAuthenticator.init(username: bob.username, password: 'password')
                                         .authenticate!).to eq(false)
      expect(Authentication::UserAuthenticator.init(username: bob.username, password: 'new')
                                         .authenticate!).to eq(true)
      expect(bob.decrypt_private_key('new')).to eq(decrypted_private_key)
    end
  end

  context 'locking' do
    it 'unlocks user' do
      bob.update(locked: true)
      bob.update(failed_login_attempts: 3)
      bob.unlock!

      expect(bob.locked?).to eq(false)
      expect(bob.failed_login_attempts).to eq(0)
    end

    it 'locks user' do
      bob.update(locked: true)

      expect(bob).to be_locked
    end

    it 'does not lock user' do
      bob.update(locked: false)

      expect(bob.locked?).to eq(false)
    end
  end

  context 'accounts' do
    it 'only returns accounts where alice is member' do
      accounts = alice.accounts
      expect(accounts.count).to eq(1)
      expect(accounts.first.name).to eq('account1')
    end
  end

  context '#update_role' do

    it 'can upgrade another user to conf admin as conf admin' do

      private_key = decrypt_private_key(conf_admin)

      bob.update_role(conf_admin, :conf_admin, private_key)

      expect(bob).to be_conf_admin

    end

    it 'can downgrade another conf admin to user as conf admin' do

      private_key = decrypt_private_key(conf_admin)

      bob.update_role(conf_admin, :conf_admin, private_key)

      bob.update_role(conf_admin, :user, private_key)

      expect(bob).to_not be_conf_admin
    end

    it 'can not be disempowered as root' do

      root = users(:root)
      root.update!(role: :admin)

      expect do
        root.send(:disempower)
      end.to raise_error('root can not be disempowered')
    end

  end

  context 'last teammember in team' do
    it 'do not destroy user if he is last teammember in any team' do
      soloteam = Fabricate(:private_team)
      user = User::Human.find(soloteam.teammembers.first.user_id)
      expect do
        user.destroy!
      end.to raise_error(Exception)
      expect(User::Human.find(user.id)).to_not be_nil
    end
  end

  context '#recrypt_private_key' do
    it 'shows new error on user if wrong old password at private_key recryption' do
      expect(bob.recrypt_private_key!('new_password', 'wrong_old_password')).to eq false

      expect(bob.errors.messages[:base][0]).to match(/Your OLD password was wrong/)
    end
  end

  context '#authenticate_db' do
    it 'authenticates db user' do
      expect(bob.authenticate_db('password')).to be true
    end

    it 'doesn\'t authenticates db user with ldap enabled' do
      enable_ldap
      expect(bob.authenticate_db('password')).to be false
    end

    it 'authenticates root with ldap enabled' do
      enable_ldap
      expect(root.authenticate_db('password')).to be true
    end

    it 'doesn\'t authenticate non db user' do
      bob.update(auth: 'ldap')
      expect(bob.authenticate_db('password')).to be false
    end
  end
end
