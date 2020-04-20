# frozen_string_literal: true

require 'rails_helper'

describe Api::AccountsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, private_key) }

  context 'GET index' do
    it 'returns account with matching name' do
      login_as(:alice)

      get :index, params: { 'q': 'acc' }, xhr: true

      account1_json = json['data']['accounts'].first

      account = accounts(:account1)
      group = account.group

      expect(account1_json['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id
      expect(account1_json['cleartext_username']).to be_nil
      expect(account1_json['cleartext_password']).to be_nil

      expect(account1_json['group']).to eq group.id
    end

    it 'returns all accounts if empty query param given' do
      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      account1_json = json['data']['accounts'].first

      account = accounts(:account1)
      group = account.group

      expect(account1_json['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id
      expect(account1_json['cleartext_username']).to be_nil
      expect(account1_json['cleartext_password']).to be_nil

      expect(account1_json['group']).to eq group.id
    end

    it 'returns all accounts if no query param given' do
      login_as(:alice)

      get :index, xhr: true

      account1_json = json['data']['accounts'].first

      account = accounts(:account1)
      group = account.group

      expect(account1_json['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id
      expect(account1_json['cleartext_username']).to be_nil
      expect(account1_json['cleartext_password']).to be_nil

      expect(account1_json['group']).to eq group.id
    end

    it 'returns account for matching description without cleartext username / password' do
      login_as(:alice)
      get :index, params: { 'q': 'des' }, xhr: true

      result_json = json['data']['accounts'].first

      account = accounts(:account1)
      group = account.group

      expect(result_json['accountname']).to eq account.accountname
      expect(result_json['id']).to eq account.id
      expect(result_json['cleartext_username']).to be_nil
      expect(result_json['cleartext_password']).to be_nil

      expect(result_json['group']).to eq group.id
    end

    it 'returns account for matching tag without cleartext username / password' do
      login_as(:bob)

      get :index, params: { 'tag': 'tag' }, xhr: true

      result_json = json['data']['account']

      account = accounts(:account2)
      group = account.group

      expect(result_json['accountname']).to eq account.accountname
      expect(result_json['id']).to eq account.id
      expect(result_json['cleartext_username']).to be_nil
      expect(result_json['cleartext_password']).to be_nil

      expect(result_json['group']).to eq group.id
    end
  end

  context 'GET show' do
    it 'returns decrypted account' do
      login_as(:bob)
      account = accounts(:account1)

      get :show, params: { id: account }, xhr: true
      account = json['data']['account']

      expect(account['accountname']).to eq 'account1'
      expect(account['cleartext_username']).to eq 'test'
      expect(account['cleartext_password']).to eq 'password'
    end

    it 'cannot authenticate and does not return decrypted account if recrypt requests pending' do
      bob.recryptrequests.create!

      login_as(:bob)
      account = accounts(:account1)

      get :show, params: { id: account }, xhr: true

      expect(errors).to include 'Wait for the recryption of your users team passwords'
      expect(response).to have_http_status 403
    end

    it 'cannot authenticate and does not return decrypted account if user not logged in' do
      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      expect(errors).to include 'User not logged in'
      expect(response).to have_http_status 401
    end

    context 'api_user' do
      it 'authenticates with valid api user and returns account details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token
        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account = json['data']['account']

        expect(account['accountname']).to eq 'account1'
        expect(account['cleartext_username']).to eq 'test'
        expect(account['cleartext_password']).to eq 'password'
      end

      it 'does not authenticate with invalid api token and does not show account details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = Base64.encode64('abcd')

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(errors).to include 'Authentification failed'
        expect(response).to have_http_status 401
      end

      it 'cannot authenticate without headers and does not show account details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(response).to have_http_status 401
        expect(errors).to include 'User not logged in'
      end

      it 'authenticates and shows account details even if recryptrequests of human user pending' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        bob.recryptrequests.create!

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        teams(:team1).add_user(api_user, plaintext_team_password)

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true
        account = json['data']['account']

        expect(response).to have_http_status 200
        expect(account['accountname']).to eq 'account1'
        expect(account['cleartext_username']).to eq 'test'
        expect(account['cleartext_password']).to eq 'password'
      end

      it 'does not show account details if valid api user not teammember' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(errors).to include 'Access denied'
        expect(response).to have_http_status 403
      end

      it 'shows account details as user and does not use user authenticator if active session' do
        login_as(:bob)

        set_auth_headers

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(Authentication::UserAuthenticator).to receive(:new).never

        account = json['data']['account']

        expect(account['accountname']).to eq 'account1'
        expect(account['cleartext_username']).to eq 'test'
        expect(account['cleartext_password']).to eq 'password'
      end

      it 'shows account as human user details if headers valid' do
        set_auth_headers

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account = json['data']['account']

        expect(account['accountname']).to eq 'account1'
        expect(account['cleartext_username']).to eq 'test'
        expect(account['cleartext_password']).to eq 'password'
      end
    end
  end

  context 'PATCH update' do
    it 'updates account with valid params structure' do
      set_auth_headers

      account = accounts(:account1)

      account_params = {
        id: account.id,
        account: {
          accountname: 'Bob Meyer',
          tag: 'taggy',
          cleartext_username: 'globi',
          cleartext_password: 'petzi'
        }
      }
      patch :update, params: account_params, xhr: true

      account.reload

      account.decrypt(plaintext_team_password)
      expect(account.accountname).to eq 'Bob Meyer'
      expect(account.tag).to eq 'taggy'
      expect(account.cleartext_username).to eq 'globi'
      expect(account.cleartext_password).to eq 'petzi'

      expect(response).to have_http_status(200)

      account = json['data']['account']

      expect(account['accountname']).to eq 'Bob Meyer'
      expect(account['cleartext_username']).to eq 'globi'
      expect(account['cleartext_password']).to eq 'petzi'
    end

    it 'cannot set account password and username attributes by params' do
      set_auth_headers

      account = accounts(:account1)

      account_params = {
        id: account.id,
        account: {
          username: 'invalid username param',
          password: 'invalid password param'
        }
      }

      patch :update, params: account_params, xhr: true

      expect(response).to have_http_status(200)

      account = json['data']['account']

      expect(account['accountname']).to eq 'account1'
      expect(account['cleartext_username']).to be_nil
      expect(account['cleartext_password']).to be_nil
    end

    it 'does not update account when user not in team' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      account = accounts(:account2)

      account_params = {
        id: account.id,
        account: {
          accountname: 'Bob Meyer',
          tag: 'taggy'
        }
      }

      patch :update, params: account_params, xhr: true

      account.reload

      expect(account.accountname).to eq 'account2'
      expect(account.tag).to eq 'tag'
      expect(response).to have_http_status(403)
    end
  end

  private

  def token
    decrypted_token = api_user.send(:decrypt_token, private_key)
    Base64.encode64(decrypted_token)
  end

  def set_auth_headers
    request.headers['Authorization-User'] = bob.username
    request.headers['Authorization-Password'] = Base64.encode64('password')
  end

  def errors
    json['messages']['errors']
  end

end
