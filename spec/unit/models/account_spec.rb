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
    '{"iv":"Z2eRDQLhiIoCLgNxuunyKw==","value":"9zUb++e6Pj7BLmCmetSwalSVvxXB2UmregR9Ldvu/NmkErDSRWck+RKjBoZWKHeSOeAeNl+tHRTlF4Q6jU5HECceAckWWPy7wWfCtZKrkss94CfJf68L8tHnAyfPnx9/VvNiomFWbUvc3IjvIDLwGXLRIn5HcAxbr+ryTYksT4EEKpRxVEihG96MrooPVFobg0/Ot/bs1tHAiYzjNoWPlBaBWzMzLP4rAvT54Lb0f5B3GZOvwmoZw7nxHP8Wy4ktH/IIQizH6In3Jk2meYsMbJyPEYvTr3g1c0IPxPURB6p+5VBe1ueDPs50YoNPz7E1L4anP3iAssIz7gZC+eUhYwwqfpewiZHLXFyWZoXXtW4UesSdVQWlV1Ih2jbV34LontH7NwlVmoXj8N6GIk4b2HqKfUkRsSE4furRlen5UEtfAPyoWsXWkmgqwKY2XfmcbIoO7d5XdGXEuMbSZsrCDUjHI+WF5JkXW7om0aJ5LehnCFvlwdN74NJWyosRKpnkKz/R+tcCinNJ9DYUeMZYSn+CPaJ2KqkMBjKjJgvy7/fOw3Du8IFVY+qsOubxnBi+gMFLdv7dTm5Y1MIN2hSZJFL3T810m/WUTAxd0wOQPinuRVpeNy4NoluNbdRkyWXIGx1Rev65k5CeR/bYnnlnoO6EmbA7/UukgpnQKHngL8ttHImV7LypqT6XZ7DGqb3bIJeR01mqNBOmGhP1LEQKEJNP2/UaRI1uvj28vOxKAaFjllsLuKb4fxk+dyxMfc/AFTOiDA2ld6Si+miBiLt+OumSz1fL6ijQpL0zghtNWnWk0VP4c++r3e/1YKvyJqwWA3aL+PyjTmu71WxR/yNwxEMjyp5UZVEjVGw+xZX3ZGUUK8vpnwpNHJMzGYjsi8aH5SCRMDhu98N0DXDbmlsmyKVpF8/Vl/BKn7nw4Xmfw7iM2YrnG7ulkPcTUno2KEwxydXFcKh4RpH49LJZLYoGhEzn/5Z/fS/LQBCkhfOt1fVHTCJWdyLkKPnXCxat0hby9VDAQ0MbeFUBZmsXEqukAI/7mKjrAq/vUsYKdcTl9ZOFvVcfdEkUFDsy5iv/uMghoA2dcFWLw0ehsosEvkHRoBEhyoY8nLW13WZl//Y1LWFgLg4EPUEbjGMGYXpF2op4F7+ahgtwbQS6jEtD9vBr0jUvurc2adDsru0IvVfdyAklhvtsVuHBSP6usvdhG7agbYeI769PRwZ0Z9YrIhZhnnaGD9hPni1tIQ9wyw3Trbqz+i1fbYJVtQyWx96np5eR/3IaydwTg5pVEh7fKukvUWOFwBmrdsX9vlE48/YMhjRtINouTWuWeWlpQvf/D1PuG9pDZ29qqJ5xIxmHb+gc/kB8w5vLQ7o/u35xGhSwHtDhwTEIa2KfTc7w4mQu1CJuDZz/1QHhNP6ZnvNqWiAdZlZUVJ3o+YWgCqMX1Y/sERf9vxSW3RkTCVm2xXppcwTKoCi4Y+9B9/5Hk5zanN1GMVu5dYFCjFv36s430JEttpkWEA1Oqe4AfZfvMsnTjLqG"}'
  end

  def cleartext_ose_secret
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end
end
