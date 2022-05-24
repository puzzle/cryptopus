# frozen_string_literal: true

require 'spec_helper'

describe Api::ApiUsers::CcliTokenController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:api_user) { bob.api_users.create!(description: 'my sweet api user') }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let(:foreign_api_user) { users(:alice).api_users.create! }

  context 'GET show' do
    context 'with default_ccli_user' do
      before(:each) do
        login_as(:bob)
        bob.update(default_ccli_user_id: api_user.id)
      end

      it 'renews token of api user' do
        old_token = api_user.send(:decrypt_token, bobs_private_key)

        get :show, xhr: true

        api_user.reload

        new_token = api_user.send(:decrypt_token, bobs_private_key)
        expect(api_user).to_not be_locked
        expect(old_token).to_not eq(new_token)
      end

      it 'renews token of api user and can still decrypt team password' do
        team = teams(:team1)
        credentials1 = encryptables(:credentials1)

        decrypted_team_password = team.decrypt_team_password(bob, bobs_private_key)
        team.add_user(api_user, decrypted_team_password)

        old_token = api_user.send(:decrypt_token, bobs_private_key)
        api_user_pk_before = api_user.decrypt_private_key(old_token)

        get :show, xhr: true

        api_user.reload

        received_token = json['token']
        token = api_user.send(:decrypt_token, bobs_private_key)

        expect(received_token).to eq(token)
        expect(api_user.authenticate_db(token)).to be true

        api_user_pk = api_user.decrypt_private_key(received_token)

        expect(api_user_pk_before).to eq(api_user_pk)

        decrypted_team_password = team.decrypt_team_password(api_user, api_user_pk)

        credentials1.decrypt(decrypted_team_password)

        expect(credentials1.cleartext_username).to eq 'test'
        expect(credentials1.cleartext_password).to eq 'password'
      end
    end

    context 'without default_ccli_user' do
      before(:each) do
        login_as(:bob)
        bob.update(default_ccli_user_id: nil)
      end

      it 'creates new api_user' do
        get :show, xhr: true

        new_api_user = bob.api_users.last

        expect(new_api_user).to_not eq(api_user)
      end

      it 'creates new api_user and can decrypt team password' do
        team = teams(:team1)
        credentials1 = encryptables(:credentials1)

        decrypted_team_password = team.decrypt_team_password(bob, bobs_private_key)

        get :show, xhr: true

        new_api_user = bob.api_users.last
        team.add_user(new_api_user, decrypted_team_password)

        new_api_user.reload

        received_token = json['token']
        token = new_api_user.send(:decrypt_token, bobs_private_key)

        expect(received_token).to eq(token)
        expect(new_api_user.authenticate_db(token)).to be true

        new_api_user_pk = new_api_user.decrypt_private_key(received_token)

        decrypted_team_password = team.decrypt_team_password(new_api_user, new_api_user_pk)

        credentials1.decrypt(decrypted_team_password)

        expect(credentials1.cleartext_username).to eq 'test'
        expect(credentials1.cleartext_password).to eq 'password'
      end
    end
  end

  private

  def token
    decrypted_token = api_user.send(:decrypt_token, bobs_private_key)
    Base64.encode64(decrypted_token)
  end
end
