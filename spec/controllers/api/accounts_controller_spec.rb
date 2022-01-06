# frozen_string_literal: true

require 'spec_helper'

describe Api::AccountsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:private_key) { bob.decrypt_private_key('password') }
  let(:plaintext_team_password) { teams(:team1).decrypt_team_password(bob, private_key) }
  let(:nested_models) { ['folder'] }
  let(:attributes) { %w[name cleartext_password cleartext_username] }
  let!(:ose_secret) { create_ose_secret }

  context 'GET index' do
    it 'returns account with matching name' do
      login_as(:alice)

      get :index, params: { 'q': 'acc' }, xhr: true

      account1_json = data.first
      account1_json_attributes = account1_json['attributes']
      account1_json_relationships = account1_json['relationships']

      account = accounts(:account1)
      folder = account.folder

      expect(account1_json_attributes['name']).to eq account.name
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['folder']['data']['id']).to eq folder.id.to_s

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
      folder = account.folder

      expect(data.count).to eq 2
      expect(account1_json_attributes['name']).to eq account.name
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['folder']['data']['id']).to eq folder.id.to_s

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
      folder = account.folder

      expect(data.count).to eq 2
      expect(account1_json_attributes['name']).to eq account.name
      expect(account1_json['id']).to eq account.id.to_s
      expect(account1_json_attributes['cleartext_username']).to be_nil
      expect(account1_json_attributes['cleartext_password']).to be_nil
      expect(account1_json_relationships['folder']['data']['id']).to eq folder.id.to_s

      expect_json_object_includes_keys(account1_json_attributes, attributes)
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'returns account for matching tag without cleartext username / password' do
      login_as(:bob)

      get :index, params: { 'tag': 'tag' }, xhr: true

      account2_json_attributes = data['attributes']
      account2_json_relationships = data['relationships']

      account = accounts(:account2)
      folder = account.folder

      expect(account2_json_attributes['name']).to eq account.name
      expect(data['id']).to eq account.id.to_s
      expect(account2_json_attributes['cleartext_username']).to be_nil
      expect(account2_json_attributes['cleartext_password']).to be_nil
      expect(account2_json_relationships['folder']['data']['id']).to eq folder.id.to_s

      expect_json_object_includes_keys(account2_json_attributes, attributes)
      expect_json_object_includes_keys(account2_json_relationships, nested_models)
    end
  end

  context 'GET show' do
    it 'returns decrypted credentials account' do
      login_as(:bob)
      account = accounts(:account1)
      rgx_date = /^(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2}).(\d{3})[+-](\d{2})\:(\d{2})/

      get :show, params: { id: account }, xhr: true

      account1_json_attributes = data['attributes']
      account1_json_relationships = data['relationships']

      expect(account1_json_attributes['name']).to eq 'account1'
      expect(account1_json_attributes['cleartext_username']).to eq 'test'
      expect(account1_json_attributes['cleartext_password']).to eq 'password'
      expect(account1_json_attributes['created_at']).to match(rgx_date)
      expect(account1_json_attributes['updated_at']).to match(rgx_date)
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'returns decrypted ose_secret account' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      get :show, params: { id: ose_secret.id }, xhr: true

      account1_json_attributes = data['attributes']
      account1_json_relationships = data['relationships']

      expect(account1_json_attributes['name']).to eq 'ose_secret'
      expect(account1_json_attributes['ose_secret']).to eq example_private_key
      expect_json_object_includes_keys(account1_json_relationships, nested_models)
    end

    it 'cannot authenticate and does not return decrypted account if user not logged in' do
      account = accounts(:account1)
      get :show, params: { id: account }, xhr: true

      expect(errors).to eq(['flashes.api.errors.user_not_logged_in'])
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

        expect(account1_json_attributes['name']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
      end

      it 'authenticates with valid api user and returns account details with oidc enabled' do
        enable_openid_connect
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']

        expect(account1_json_attributes['name']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
      end

      it 'authenticates with valid api user and returns account details with ldap enabled' do
        enable_ldap
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token
        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']

        expect(account1_json_attributes['name']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
      end

      it 'does not authenticate with invalid api token and does not show account details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = Base64.encode64('abcd')

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(errors).to eq(['flashes.api.errors.auth_failed'])
        expect(response).to have_http_status 401
      end

      it 'cannot authenticate without headers and does not show account details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, plaintext_team_password)

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(response).to have_http_status 401
        expect(errors).to eq(['flashes.api.errors.user_not_logged_in'])
      end

      it 'does not show account details if valid api user not teammember' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        expect(errors).to eq(['flashes.admin.admin.no_access'])
        expect(response).to have_http_status 403
      end

      it 'shows account details as user and does not use user authenticator if active session' do
        login_as(:bob)

        set_auth_headers

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']

        expect(response).to have_http_status(200)
        expect(account1_json_attributes['name']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
      end

      it 'shows account as human user details if headers valid' do
        set_auth_headers

        account = accounts(:account1)
        get :show, params: { id: account }, xhr: true

        account1_json_attributes = data['attributes']
        account1_json_relationships = data['relationships']

        expect(response).to have_http_status(200)
        expect(account1_json_attributes['name']).to eq 'account1'
        expect(account1_json_attributes['cleartext_username']).to eq 'test'
        expect(account1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(account1_json_relationships, nested_models)
      end
    end
  end

  context 'PATCH update' do
    it 'updates credentials account with valid params structure' do
      set_auth_headers

      account = accounts(:account1)

      account_params = {
        data: {
          id: account.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          },
          relationships: { folder: { data: { id: account.folder_id, type: 'folders' } } }
        }, id: account.id
      }
      patch :update, params: account_params, xhr: true

      account.reload

      account1_json_attributes = data['attributes']

      account.decrypt(plaintext_team_password)
      expect(account1_json_attributes['name']).to eq 'Bob Meyer'
      expect(account1_json_attributes['cleartext_username']).to eq 'globi'
      expect(account1_json_attributes['cleartext_password']).to eq 'petzi'

      expect(response).to have_http_status(200)
    end

    it 'updates ose_secret account with valid params structure and adjust data property' do
      set_auth_headers

      account = ose_secret
      updated_ose_secret_data = {
        name: 'example secret',
        password: 'dvF2jc1JA'
      }.to_yaml
      account_params = {
        data: {
          id: account.id,
          attributes: {
            name: 'updated ose secret',
            ose_secret: updated_ose_secret_data
          },
          relationships: { folder: { data: { id: account.folder_id, type: 'folders' } } }
        }, id: account.id
      }
      patch :update, params: account_params, xhr: true

      account.reload

      account.decrypt(plaintext_team_password)
      expect(account.name).to eq 'updated ose secret'
      expect(account.ose_secret).to eq updated_ose_secret_data

      expect(response).to have_http_status(200)
    end

    it 'moves account to other team' do
      login_as(:bob)

      account = accounts(:account1)
      target_folder = folders(:folder2)

      account_params = {
        data: {
          id: account.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          },
          relationships: { folder: { data: { id: target_folder.id, type: 'folders' } } }
        }, id: account.id
      }
      patch :update, params: account_params, xhr: true

      account.reload

      plaintext_team2_password = teams(:team2).decrypt_team_password(bob, private_key)
      account.decrypt(plaintext_team2_password)
      file_entry = account.file_entries.first
      file_entry.decrypt(plaintext_team2_password)

      expect(account.cleartext_username).to eq 'globi'
      expect(account.cleartext_password).to eq 'petzi'
      expect(file_entry.cleartext_file).to eq 'Das ist ein test File'

      expect(response).to have_http_status(200)
    end

    it 'updates account but does not move without team membership' do
      login_as(:alice)

      account = accounts(:account1)
      new_folder = folders(:folder2)

      account_params = {
        data: {
          id: account.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          },
          relationships: { folder: { data: { id: new_folder.id, type: 'folders' } } }
        }, id: account.id
      }
      patch :update, params: account_params, xhr: true

      expect(response.status).to be(403)
      expect(errors).to eq(['flashes.admin.admin.no_access'])

      account.reload

      plaintext_team2_password = teams(:team2).decrypt_team_password(bob, private_key)
      expect do
        account.decrypt(plaintext_team2_password)
      end.to raise_error(OpenSSL::Cipher::CipherError, 'bad decrypt')

      file_entry = account.file_entries.first
      expect do
        file_entry.decrypt(plaintext_team2_password)
      end.to raise_error(OpenSSL::Cipher::CipherError, 'bad decrypt')
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
          },
          relationships: { folder: { data: { id: account.folder_id, type: 'folders' } } }
        }, id: account.id
      }

      patch :update, params: account_params, xhr: true

      account1_json_attributes = data['attributes']

      expect(account1_json_attributes['name']).to eq 'account1'
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
            name: 'Bob Meyer',
            tag: 'taggy'
          }
        },
        id: account.id
      }

      patch :update, params: account_params, xhr: true

      account.reload

      expect(account.name).to eq 'account2'
      expect(account.tag).to eq 'tag'
      expect(response).to have_http_status(403)
    end

    it 'updates openshift secret as api user' do
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      teams(:team1).add_user(api_user, plaintext_team_password)

      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token

      account = ose_secret

      account_params = {
        data: {
          id: account.id,
          attributes: {
            name: 'updated secret',
            tag: 'taggy'
          },
          relationships: { folder: { data: { id: account.folder_id, type: 'folders' } } }
        }, id: account.id
      }
      patch :update, params: account_params, xhr: true

      account.reload

      account1_json_attributes = data['attributes']

      account.decrypt(plaintext_team_password)
      expect(account1_json_attributes['name']).to eq 'updated secret'

      expect(response).to have_http_status(200)
    end
  end

  context 'POST create' do
    it 'creates a new account if part of team' do
      set_auth_headers

      login_as(:alice)
      folder = folders(:folder1)

      new_account_params = {
        data: {
          attributes: {
            type: 'credentials',
            name: 'New Account'
          },
          relationships: {
            folder: {
              data: {
                id: folder.id,
                type: 'folders'
              }
            }
          }
        }
      }

      post :create, params: new_account_params, xhr: true

      expect(response).to have_http_status(201)
      expect(data['attributes']['name']).to eq 'New Account'
    end

    it 'cannot create a new account if part of team' do
      set_auth_headers

      login_as(:alice)
      folder = folders(:folder2)

      new_account_params = {
        data: {
          attributes: {
            name: 'New Account'
          },
          relationships: {
            folder: {
              data: {
                id: folder.id,
                type: 'folders'
              }
            }
          }
        }
      }

      post :create, params: new_account_params, xhr: true

      expect(response).to have_http_status(403)
    end

    it 'creates new openshift secret if api user' do
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      teams(:team1).add_user(api_user, plaintext_team_password)

      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token

      folder = folders(:folder1)

      new_account_params = {
        data: {
          attributes: {
            name: 'New Account',
            type: 'ose_secret'
          },
          relationships: {
            folder: {
              data: {
                id: folder.id,
                type: 'folders'
              }
            }
          }
        }
      }

      expect do
        post :create, params: new_account_params, xhr: true
      end.to change { Account.count }.by(1)

      expect(response).to have_http_status(201)
    end

    context 'DELETE destroy' do
      it 'cant destroy an account if not in team' do
        login_as(:alice)

        alice = users(:alice)
        team2 = teams(:team2)
        account = team2.folders.first.accounts.first

        expect(team2.teammember?(alice)).to eq false

        expect do
          delete :destroy, params: { id: account.id, folder_id: account.folder.id,
                                     team_id: account.folder.team.id }
        end.to change { Account.count }.by(0)
      end

      it 'can destroy an account if human user is in his team' do
        account = accounts(:account1)

        login_as(:bob)

        expect do
          delete :destroy, params: { id: account.id, folder_id: account.folder.id,
                                     team_id: account.folder.team.id }
        end.to change { Account.count }.by(-1)
      end
    end
  end

  private

  def create_ose_secret
    secret = Account::OSESecret.new(name: 'ose_secret',
                                    folder: folders(:folder1),
                                    ose_secret: example_private_key)

    secret.encrypt(plaintext_team_password)
    secret.save!
    secret
  end

  def example_private_key
    Base64.strict_decode64(FixturesHelper.read_account_file('example_secret.secret'))
  end

  def token
    decrypted_token = api_user.send(:decrypt_token, private_key)
    Base64.encode64(decrypted_token)
  end

  def set_auth_headers
    request.headers['Authorization-User'] = bob.username
    request.headers['Authorization-Password'] = Base64.encode64('password')
  end
end
