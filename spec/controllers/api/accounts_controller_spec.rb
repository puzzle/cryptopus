# frozen_string_literal: true

require 'rails_helper'

describe Api::AccountsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, private_key) }
  let(:nested_models) { ['group'] }
  let(:attributes) { %w[accountname cleartext_password cleartext_username] }

  context 'GET index' do
    it 'returns account with matching name' do
      login_as(:alice)

      get :index, params: { 'q': 'acc' }, xhr: true

      account1_json = data.first
      account1_json_attributes = account1_json['attributes']
      account1_json_relationships = account1_json['relationships']

      account = accounts(:account1)
      group = account.group

      expect(account1_json_attributes['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['group']['data']['id']).to eq group.id.to_s

      expect_json_object_includes_keys(account1_json_attributes, attributes)
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'returns all accounts if empty query param given' do
      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      account1_json = data.first
      account1_json_attributes = account1_json['attributes']
      account1_json_relationships = account1_json['relationships']

      account = accounts(:account1)
      group = account.group

      expect(data.count).to eq 1
      expect(account1_json_attributes['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['group']['data']['id']).to eq group.id.to_s

      expect_json_object_includes_keys(account1_json_attributes, attributes)
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'returns all accounts if no query param given' do
      login_as(:alice)

      get :index, xhr: true

      account1_json = data.first
      account1_json_attributes = account1_json['attributes']
      account1_json_relationships = account1_json['relationships']

      account = accounts(:account1)
      group = account.group

      expect(data.count).to eq 1
      expect(account1_json_attributes['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['group']['data']['id']).to eq group.id.to_s

      expect_json_object_includes_keys(account1_json_attributes, attributes)
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'returns account for matching description without cleartext username / password' do
      login_as(:alice)
      get :index, params: { 'q': 'des' }, xhr: true

      account1_json = data.first
      account1_json_attributes = account1_json['attributes']
      account1_json_relationships = account1_json['relationships']

      account = accounts(:account1)
      group = account.group

      expect(data.count).to eq 1
      expect(account1_json_attributes['accountname']).to eq account.accountname
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['group']['data']['id']).to eq group.id.to_s

      expect_json_object_includes_keys(account1_json_attributes, attributes)
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'returns account for matching tag without cleartext username / password' do
      login_as(:bob)

      get :index, params: { 'tag': 'tag' }, xhr: true

      account2_json_attributes = data['attributes']
      account2_json_relationships = data['relationships']

      account = accounts(:account2)
      group = account.group

      expect(account2_json_attributes['accountname']).to eq account.accountname
      expect(data['id']).to eq account.id.to_s
      expect(account2_json_attributes['cleartext_username']).to be_nil
      expect(account2_json_attributes['cleartext_password']).to be_nil
      expect(account2_json_relationships['group']['data']['id']).to eq group.id.to_s

      expect_json_object_includes_keys(account2_json_attributes, attributes)
      expect_json_object_includes_keys(account2_json_relationships, nested_models)
    end
  end

  context 'GET show' do
    it 'returns decrypted account' do
      login_as(:bob)
      account = accounts(:account1)

      get :show, params: { id: account }, xhr: true

      account1_json_attributes = data['attributes']
      account1_json_relationships = data['relationships']
      group_attributes = json['included'].first['attributes']

      expect(account1_json_attributes['accountname']).to eq 'account1'
      expect(account1_json_attributes['cleartext_username']).to eq 'test'
      expect(account1_json_attributes['cleartext_password']).to eq 'password'
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
      expect(group_attributes['name']).to eq 'group1'
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

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']
        group_attributes = json['included'].first['attributes']

        expect(account1_json_attributes['accountname']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
        expect(group_attributes['name']).to eq 'group1'
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

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']
        group_attributes = json['included'].first['attributes']

        expect(response).to have_http_status(200)
        expect(account1_json_attributes['accountname']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
        expect(group_attributes['name']).to eq 'group1'
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

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']
        group_attributes = json['included'].first['attributes']

        expect(response).to have_http_status(200)
        expect(account1_json_attributes['accountname']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
        expect(group_attributes['name']).to eq 'group1'
      end

      it 'shows account as human user details if headers valid' do
        set_auth_headers

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']
        group_attributes = json['included'].first['attributes']

        expect(response).to have_http_status(200)
        expect(account1_json_attributes['accountname']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
        expect(group_attributes['name']).to eq 'group1'
      end
    end
  end

  context 'PATCH update' do
    it 'updates account with valid params structure' do
      set_auth_headers

      account = accounts(:account1)

      account_params = {
        data: {
          id: account.id,
          attributes: {
            accountname: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          }
        }, id: account.id
      }
      patch :update, params: account_params, xhr: true

      account.reload

      account1_json_attributes = data['attributes']

      account.decrypt(plaintext_team_password)
      expect(account1_json_attributes['accountname']).to eq 'Bob Meyer'
      expect(account1_json_attributes['cleartext_username']).to eq 'globi'
      expect(account1_json_attributes['cleartext_password']).to eq 'petzi'

      expect(response).to have_http_status(200)
    end

    it 'cannot set account password and username attributes by params' do
      set_auth_headers

      account = accounts(:account1)

      account_params = {
        data: {
          id: account.id,
          attributes: {
            username: 'invalid username param',
            password: 'invalid password param'
          }
        }, id: account.id
      }

      patch :update, params: account_params, xhr: true

      account1_json_attributes = data['attributes']

      expect(account1_json_attributes['accountname']).to eq 'account1'
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
    end

    it 'does not update account when user not in team' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      account = accounts(:account2)

      account_params = {
        data: {
          id: account.id,
          attributes: {
            accountname: 'Bob Meyer',
            tag: 'taggy'
          }
        },
        id: account.id
      }

      patch :update, params: account_params, xhr: true

      account.reload

      expect(account.accountname).to eq 'account2'
      expect(account.tag).to eq 'tag'
      expect(response).to have_http_status(403)
    end
  end

  context 'POST create' do
    it 'creates a new account if part of team' do
      set_auth_headers

      login_as(:alice)
      group = groups(:group1)

      new_account_params = {
        data: {
          attributes: {
            accountname: 'New Account'
          },
          relationships: {
            group: {
              data: {
                id: group.id,
                type: 'groups'
              }
            }
          }
        }
      }

      post :create, params: new_account_params, xhr: true

      expect(response).to have_http_status(200)
      expect(data['attributes']['accountname']).to eq 'New Account'
    end

    it 'cannot create a new account if part of team' do
      set_auth_headers

      login_as(:alice)
      group = groups(:group2)

      new_account_params = {
        data: {
          attributes: {
            accountname: 'New Account'
          },
          relationships: {
            group: {
              data: {
                id: group.id,
                type: 'groups'
              }
            }
          }
        }
      }

      post :create, params: new_account_params, xhr: true

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
end
