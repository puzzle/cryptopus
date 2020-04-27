# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe User::Human do

  let(:bob) { users(:bob) }
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

      expect(bob.authenticate('password')).to eq(false)
      expect(bob.authenticate('new')).to eq(true)
      expect(bob.decrypt_private_key('new')).to eq(decrypted_private_key)
    end
  end

  context 'legacy encrypted private key' do
    it 'updates private key if legacy private key' do
      decrypted_private_key = bob.decrypt_private_key('password')
      bob.update(private_key: legacy_encrypt_private_key(decrypted_private_key, 'password'))

      expect(bob.decrypt_private_key('password')).to eq(decrypted_private_key)
      expect(bob.legacy_private_key?).to eq(false)
    end
  end

  context 'legacy password' do

    it 'has legacy password if password is updated' do
      hash = Digest::MD5.hexdigest('password')
      bob.update(password: hash)

      expect(bob.legacy_password?).to eq(true)
    end

    it 'cant have legacy password as ldap user' do
      hash = Digest::MD5.hexdigest('password')
      bob.update(password: hash)
      bob.auth = 'ldap'

      expect(bob.legacy_password?).to eq(false)
    end

  end

  context 'locking' do

    it 'unlocks user' do
      bob.update(locked: true)
      bob.update(failed_login_attempts: 3)

      bob.unlock

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

    it 'only returns accounts where bob is member' do
      accounts = alice.accounts
      expect(accounts.count).to eq(1)
      expect(accounts.first.accountname).to eq('account1')
    end

  end

  context 'ldap' do

    it 'creates user from ldap' do
      enable_ldap
      ldap_mock = double

      expect(LdapConnection).to receive(:new).exactly(3).times.and_return(ldap_mock)
      expect(ldap_mock).to receive(:uidnumber_by_username).and_return('42')
      expect(ldap_mock).to receive(:ldap_info).with('42', 'givenname').and_return('bob')
      expect(ldap_mock).to receive(:ldap_info).with('42', 'sn').and_return('test')

      user = User::Human.send(:create_from_ldap, 'bob', 'password')

      expect(user.username).to eq('bob')
      expect(user.provider_uid).to eq('42')
      expect(user.givenname).to eq('bob')
      expect(user.surname).to eq('test')
      expect(user.auth).to eq('ldap')
    end

    it 'cannot auth against ldap if ldap disabled' do
      bob.update(auth: 'ldap')

      expect_any_instance_of(LdapConnection).to receive(:authenticate!).never

      expect do
        bob.authenticate('password')
      end.to raise_error('cannot authenticate against ldap since ldap auth is disabled')
    end

  end

  context '#find_or_create_from_ldap' do

    it 'returns user if exists in db' do
      user = User::Human.find_or_import_from_ldap('bob', 'password')
      expect(user).to_not be_nil
      expect(user.username).to eq('bob')
    end

    it 'does not return user if user not exists in db and ldap' do
      enable_ldap
      mock_ldap_settings

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .with('nobody', 'password').and_return(false)
      expect(User::Human).to receive(:create_from_ldap).never

      user = User::Human.find_or_import_from_ldap('nobody', 'password')
      expect(user).to be_nil
    end

    it 'does not return user if user not exists in db and ldap disabled' do
      expect_any_instance_of(LdapConnection).to receive(:authenticate!).never

      user = User::Human.find_or_import_from_ldap('nobody', 'password')
      expect(user).to be_nil
    end

    it 'imports and creates user from ldap' do
      enable_ldap
      mock_ldap_settings

      expect_any_instance_of(LdapConnection)
        .to receive(:authenticate!)
        .with('nobody', 'password').and_return(true)
      expect(User::Human).to receive(:create_from_ldap)

      user = User::Human.find_or_import_from_ldap('nobody', 'password')

      expect(user).to be_nil
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
      enable_ldap
      mock_ldap_settings

      bob.update(auth: 'ldap')

      expect_any_instance_of(LdapConnection).to receive(:authenticate!).and_return(true)

      expect(bob.recrypt_private_key!('new_password', 'wrong_old_password')).to eq false

      expect(bob.errors.messages[:base][0]).to match(/Your OLD password was wrong/)
    end

    it 'shows new error on user if wrong new password at private_key recryption' do
      expect(bob.recrypt_private_key!('worong_new_password', 'password')).to eq false

      expect(bob.errors.messages[:base][0]).to match(/Your NEW password was wrong/)
    end
  end
end
