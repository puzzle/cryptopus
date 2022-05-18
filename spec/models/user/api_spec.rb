# frozen_string_literal: true

#  Copyright (c) 2008-2018, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe User::Api do

  let(:bob) { users(:bob) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }

  context '#create' do

    it 'creates new token for human user' do
      api_user = bob.api_users.create!(description: 'firefox plugin')
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      token = decrypted_token(api_user)
      expect(token).to match(/\A[a-z0-9]{32}\z/)
      expect(authenticate(api_user.username, token)).to eq(true)
      expect(api_user.username).to match(/\Abob-[a-z0-9]{6}\z/)
      expect(api_user.valid_for).to eq(60)
    end

    it 'fails creation if no human user assigned' do
      api_user = User::Api.create

      expect(api_user).to_not be_persisted
      expect(api_user.errors.messages[:username].first).to match(/can't be blank/)
      expect(api_user.errors.messages[:human_user].first).to match(/can't be blank/)
    end

    it 'is invalid if invalid value for valid_for option' do
      api_user = bob.api_users.new(description: 'api-access')
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      [42, -20, -1].each do |v|
        api_user.valid_for = v
        expect(api_user).to_not be_valid
        expect(api_user.errors.messages[:valid_for].first).to match(/is not included in the list/)
      end
    end

    it 'is valid if valid value for valid_for option' do
      api_user = bob.api_users.new(description: 'api-access')
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      [1.minute.seconds, 5.minutes.seconds,
       12.hours.seconds, 0].each do |v|
        api_user.valid_for = v
        expect(api_user).to be_valid
        expect(api_user.valid_for).to eq(v)
      end
    end

    context 'personal_team' do

      it 'does not create personal_team for API user' do
        user = bob.api_users.create!(username: 'APIAlice')
        expect(Team::Personal.where(personal_owner_id: user.id)).not_to be_present
      end
    end
  end

  context '#renew_token_by_human' do

    it 'creates new token and updates expiring time' do
      now = Time.zone.now
      api_user = bob.api_users.create!
      api_user.valid_for = 5.minutes.seconds
      api_user.valid_until = now

      expect(Time).to receive(:now).at_least(:once).and_return(now)

      new_token = api_user.renew_token_by_human(bob.decrypt_private_key('password'))

      expect(api_user.valid_until.to_i).to eq(now.advance(seconds: 5.minutes.seconds).to_i)
      expect(authenticate(api_user.username, new_token)).to eq(true)
      expect(decrypted_token(api_user)).to eq(new_token)
      expect(api_user).to_not be_expired
      expect(api_user).to_not be_locked
    end

    it 'creates new token which never expires' do
      api_user = bob.api_users.create!
      api_user.valid_for = 0

      new_token = api_user.renew_token_by_human(bob.decrypt_private_key('password'))
      expect(api_user.valid_until).to be_nil
      expect(decrypted_token(api_user)).to eq(new_token)
      expect(api_user).to_not be_expired
      expect(api_user).to_not be_locked
    end

  end

  context '#renew_token' do

    it 'renews his own token and human user may decrypt token' do
      now = Time.zone.now
      api_user = bob.api_users.create!
      api_user.valid_for = 5.minutes.seconds
      api_user.valid_until = now

      expect(Time).to receive(:now).at_least(:once).and_return(now)

      token = api_user.renew_token_by_human(bob.decrypt_private_key('password'))

      # api user renews his token
      new_token = api_user.renew_token(token)
      expect(decrypted_token(api_user)).to eq(new_token)
      expect(api_user.valid_until.to_i).to eq(now.advance(seconds: 5.minutes.seconds).to_i)
      expect(authenticate(api_user.username, new_token)).to eq(true)
      expect(api_user).to_not be_expired
      expect(api_user).to_not be_locked

      # human user should be able to renew it again
      new_token = api_user.renew_token_by_human(bob.decrypt_private_key('password'))
      expect(authenticate(api_user.username, new_token)).to eq(true)
    end
  end

  context '#locked' do
    it 'does not lock api user on creation' do
      api_user = bob.api_users.create
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      expect(bob).to_not be_locked
      expect(api_user).to_not be_locked
    end

    it 'locks api user' do
      api_user = bob.api_users.create
      api_user.update!(valid_until: Time.zone.now + 5.minutes)
      api_user.update!(locked: true)

      expect(bob).to_not be_locked
      expect(api_user).to be_locked
    end

    it 'locks human user' do
      api_user = bob.api_users.create

      bob.update!(locked: true)
      api_user.reload

      expect(bob).to be_locked
      expect(api_user).to be_locked
    end
  end

  context '#expired' do
    it 'does not expire api user if valid_until has not passed yet' do
      api_user = bob.api_users.create

      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      expect(api_user).to_not be_expired
    end

    it 'expires api user if valid_until has not passed yet' do
      api_user = bob.api_users.create

      api_user.update!(valid_until: Time.zone.now - 5.minutes)

      expect(api_user).to be_expired
    end

    it 'expires api user if valid until nil' do
      api_user = bob.api_users.create

      expect(api_user.valid_until).to be_nil
      expect(api_user).to be_expired
    end
  end

  context '#authenticate_db' do
    it 'authenticates api user' do
      api_user = bob.api_users.create!(description: 'firefox plugin')
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      token = decrypted_token(api_user)
      expect(api_user.authenticate_db(token)).to be true
    end

    it 'authenticates api user even with ldap enabled' do
      enable_ldap
      api_user = bob.api_users.create!(description: 'firefox plugin')
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      token = decrypted_token(api_user)
      expect(api_user.authenticate_db(token)).to be true
    end
  end

  private

  def authenticate(username, token)
    Authentication::UserAuthenticator.init(
      username: username, password: token
    ).authenticate_by_headers!
  end

  def decrypted_token(api_user)
    api_user.send(:decrypt_token, bobs_private_key)
  end
end
