# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'
describe Account do

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:account) { accounts(:account1) }
  let(:team) { teams(:team1) }

  it 'does not create second account in same folder' do
    params = {}
    params[:name] = 'account1'
    params[:folder_id] = folders(:folder1).id
    params[:type] = 'Account::Credentials'
    account = Account.new(params)
    expect(account).to_not be_valid
    expect(account.errors.keys).to eq([:name])
  end

  it 'creates second account' do
    params = {}
    params[:name] = 'account1'
    params[:folder_id] = folders(:folder2).id
    params[:type] = 'Account::Credentials'
    account = Account.new(params)
    expect(account).to be_valid
  end

  it 'decrypts username and password' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account.decrypt(team_password)

    expect(account.cleartext_username).to eq('test')
    expect(account.cleartext_password).to eq('password')
  end

  it 'updates password and username' do
    team_password = team.decrypt_team_password(bob, bobs_private_key)

    account.cleartext_username = 'new'
    account.cleartext_password = 'foo'

    account.encrypt(team_password)
    account.save!
    account.reload
    account.decrypt(team_password)

    expect(account.cleartext_username).to eq('new')
    expect(account.cleartext_password).to eq('foo')
  end

  it 'does not create account if name is empty' do
    params = {}
    params[:name] = ''
    params[:description] = 'foo foo'
    params[:type] = 'Account::Credentials'

    account = Account.new(params)

    account.encrypted_data[:password] = { data: 'foo', iv: nil }
    account.encrypted_data[:username] = { data: 'foo', iv: nil }

    expect(account).to_not be_valid
    expect(account.errors.full_messages.first).to match(/Name/)
  end

  context 'ose secret' do
    let!(:legacy_ose_secret) { create_legacy_ose_secret }

    it 'converts legacy ose secret during decrypt' do
      expect(legacy_ose_secret.send(:legacy_encrypted_data?)).to eq(true)

      legacy_ose_secret.decrypt(team1_password)

      ose_secret = Account::OSESecret.find(legacy_ose_secret.id)

      expect(ose_secret.send(:legacy_encrypted_data?)).to eq(false)

      ose_secret.decrypt(team1_password)
      expect(ose_secret.cleartext_ose_secret).to eq(cleartext_ose_secret)
    end
  end

  private

  def create_legacy_ose_secret
    secret = Account::OSESecret.new(name: 'ose_secret',
                                    folder: folders(:folder1))

    secret.save!
    secret.write_attribute(:encrypted_data, legacy_ose_secret_data)
    secret
  end

  def legacy_ose_secret_data
    value = Base64.strict_decode64(FixturesHelper.read_account_file('legacy_ose_secret.encrypted_data'))
    { iv: 'Z2eRDQLhiIoCLgNxuunyKw==', value: value }.to_json
  end

  def cleartext_ose_secret
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end
end
