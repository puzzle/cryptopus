# frozen_string_literal: true

require 'spec_helper'

describe Api::EncryptablesController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:private_key) { bob.decrypt_private_key('password') }
  let(:nested_models) { ['folder'] }
  let(:attributes) { %w[name cleartext_password cleartext_username] }
  let!(:ose_secret) { create_ose_secret }
  let(:credentials1) { encryptables(:credentials1) }

  context 'GET index' do
    it 'returns encryptable with matching name' do
      login_as(:alice)

      get :index, params: { 'q': 'Personal' }, xhr: true

      credentials1_json = data.first
      credentials1_json_attributes = credentials1_json['attributes']
      credentials1_json_relationships = credentials1_json['relationships']

      expect(credentials1_json_attributes['name']).to eq credentials1.name
      expect(credentials1_json['id']).to eq credentials1.id.to_s
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil

      expect(credentials1_json_relationships['folder']['data']['id'])
        .to eq credentials1.folder_id.to_s

      expect_json_object_includes_keys(credentials1_json_attributes, attributes)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns all enncryptables if empty query param given' do
      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      credentials1_json = data.first
      credentials1_json_attributes = credentials1_json['attributes']
      credentials1_json_relationships = credentials1_json['relationships']

      expect(data.count).to eq 2
      expect(credentials1_json_attributes['name']).to eq credentials1.name
      expect(credentials1_json['id']).to eq credentials1.id.to_s
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
      expect(credentials1_json_relationships['folder']['data']['id'])
        .to eq credentials1.folder_id.to_s

      expect_json_object_includes_keys(credentials1_json_attributes, attributes)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns all encryptables if no query param given' do
      login_as(:alice)

      get :index, xhr: true

      credentials1_json = data.first
      credentials1_json_attributes = credentials1_json['attributes']
      credentials1_json_relationships = credentials1_json['relationships']

      expect(data.count).to eq 2
      expect(credentials1_json_attributes['name']).to eq credentials1.name
      expect(credentials1_json['id']).to eq credentials1.id.to_s
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
      expect(credentials1_json_relationships['folder']['data']['id'])
        .to eq credentials1.folder_id.to_s

      expect_json_object_includes_keys(credentials1_json_attributes, attributes)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns encryptable for matching tag without cleartext username / password' do
      login_as(:bob)

      get :index, params: { 'tag': 'tag' }, xhr: true

      credentials2_json_attributes = data['attributes']
      credentials2_json_relationships = data['relationships']

      credentials2 = encryptables(:credentials2)

      expect(credentials2_json_attributes['name']).to eq credentials2.name
      expect(data['id']).to eq credentials2.id.to_s
      expect(credentials2_json_attributes['cleartext_username']).to be_nil
      expect(credentials2_json_attributes['cleartext_password']).to be_nil
      expect(credentials2_json_relationships['folder']['data']['id'])
        .to eq credentials2.folder_id.to_s

      expect_json_object_includes_keys(credentials2_json_attributes, attributes)
      expect_json_object_includes_keys(credentials2_json_relationships, nested_models)
    end
  end

  context 'GET show' do
    it 'returns decrypted encryptable credentials' do
      login_as(:bob)
      rgx_date = /^(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2}).(\d{3})[+-](\d{2})\:(\d{2})/

      get :show, params: { id: credentials1 }, xhr: true

      credentials1_json_attributes = data['attributes']
      credentials1_json_relationships = data['relationships']

      expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
      expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
      expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
      expect(credentials1_json_attributes['created_at']).to match(rgx_date)
      expect(credentials1_json_attributes['updated_at']).to match(rgx_date)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns decrypted ose secret' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      get :show, params: { id: ose_secret.id }, xhr: true

      ose_secret_json_attributes = data['attributes']
      ose_secret_json_relationships = data['relationships']

      expect(ose_secret_json_attributes['name']).to eq 'Rails Secret Key Base'
      expect(ose_secret_json_attributes['cleartext_ose_secret']).to eq example_ose_secret_yaml
      expect_json_object_includes_keys(ose_secret_json_relationships, nested_models)
    end

    it 'cannot authenticate and does not return decrypted encryptable if user not logged in' do
      get :show, params: { id: credentials1.id }, xhr: true

      expect(errors).to eq(['flashes.api.errors.user_not_logged_in'])
      expect(response).to have_http_status 401
    end

    context 'api_user' do
      it 'authenticates with valid api user and returns encryptable details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, team1_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token
        get :show, params: { id: credentials1 }, xhr: true

        credentials1_json_attributes = data['attributes']
        credentials1_json_relationships = data['relationships']

        expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
        expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
        expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
      end

      it 'authenticates with valid api user and returns encryptable details with oidc enabled' do
        enable_openid_connect
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, team1_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        get :show, params: { id: credentials1 }, xhr: true

        credentials1_json_attributes = data['attributes']
        credentials1_json_relationships = data['relationships']

        expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
        expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
        expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
      end

      it 'authenticates with valid api user and returns encryptable details with ldap enabled' do
        enable_ldap
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, team1_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        get :show, params: { id: credentials1 }, xhr: true

        credentials1_json_attributes = data['attributes']
        credentials1_json_relationships = data['relationships']

        expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
        expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
        expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
      end

      it 'does not authenticate with invalid api token and does not show encryptable details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, team1_password)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = Base64.encode64('abcd')

        get :show, params: { id: credentials1.id }, xhr: true

        expect(errors).to eq(['flashes.api.errors.auth_failed'])
        expect(response).to have_http_status 401
      end

      it 'cannot authenticate without headers and does not show encryptable details' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        teams(:team1).add_user(api_user, team1_password)

        get :show, params: { id: credentials1.id }, xhr: true

        expect(response).to have_http_status 401
        expect(errors).to eq(['flashes.api.errors.user_not_logged_in'])
      end

      it 'does not show encryptable details if valid api user not teammember' do
        api_user.update!(valid_until: Time.zone.now + 5.minutes)

        request.headers['Authorization-User'] = api_user.username
        request.headers['Authorization-Password'] = token

        get :show, params: { id: credentials1 }, xhr: true

        expect(errors).to eq(['flashes.admin.admin.no_access'])
        expect(response).to have_http_status 403
      end

      it 'prefers active session over authentication by headers' do
        login_as(:bob)

        set_auth_headers

        expect(Authentication::UserAuthenticator).to receive(:init).never

        get :show, params: { id: credentials1.id }, xhr: true

        credentials1_json_attributes = data['attributes']
        credentials1_json_relationships = data['relationships']

        expect(response).to have_http_status(200)
        expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
        expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
        expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
      end

      it 'shows encryptable as human user details if headers valid' do
        set_auth_headers

        get :show, params: { id: credentials1.id }, xhr: true

        credentials1_json_attributes = data['attributes']
        credentials1_json_relationships = data['relationships']

        expect(response).to have_http_status(200)
        expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
        expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
        expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
        expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
      end
    end
  end

  context 'PATCH update' do
    it 'updates credentials encryptable with valid params structure' do
      set_auth_headers

      credentials1 = encryptables(:credentials1)

      encryptable_params = {
        data: {
          id: credentials1.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          },
          relationships: { folder: { data: { id: credentials1.folder_id, type: 'folders' } } }
        }, id: credentials1.id
      }
      patch :update, params: encryptable_params, xhr: true

      credentials1.reload

      credentials1_json_attributes = data['attributes']

      credentials1.decrypt(team1_password)
      expect(credentials1_json_attributes['name']).to eq 'Bob Meyer'
      expect(credentials1_json_attributes['cleartext_username']).to eq 'globi'
      expect(credentials1_json_attributes['cleartext_password']).to eq 'petzi'

      expect(response).to have_http_status(200)
    end

    it 'updates ose secret encryptable with valid params structure and adjust data property' do
      set_auth_headers

      encryptable = ose_secret
      updated_ose_secret_data = {
        name: 'example secret',
        password: 'dvF2jc1JA'
      }.to_yaml
      encryptable_params = {
        data: {
          id: encryptable.id,
          attributes: {
            name: 'updated ose secret',
            cleartext_ose_secret: updated_ose_secret_data
          },
          relationships: { folder: { data: { id: encryptable.folder_id, type: 'folders' } } }
        }, id: encryptable.id
      }
      patch :update, params: encryptable_params, xhr: true

      encryptable.reload
      encryptable.decrypt(team1_password)

      expect(encryptable.name).to eq 'updated ose secret'
      expect(encryptable.cleartext_ose_secret).to eq updated_ose_secret_data

      expect(response).to have_http_status(200)
    end

    it 'moves encryptable to other team' do
      login_as(:bob)

      credentials1 = encryptables(:credentials1)
      target_folder = folders(:folder2)

      encryptable_params = {
        data: {
          id: credentials1.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          },
          relationships: { folder: { data: { id: target_folder.id, type: 'folders' } } }
        }, id: credentials1.id
      }
      patch :update, params: encryptable_params, xhr: true

      credentials1.reload

      credentials1.decrypt(team2_password)
      file_entry = credentials1.file_entries.first
      file_entry.decrypt(team2_password)

      expect(credentials1.cleartext_username).to eq 'globi'
      expect(credentials1.cleartext_password).to eq 'petzi'
      expect(file_entry.cleartext_file).to eq 'Das ist ein test File'

      expect(response).to have_http_status(200)
    end

    it 'updates encryptable but does not move without team membership' do
      login_as(:alice)

      credentials1 = encryptables(:credentials1)
      new_folder = folders(:folder2)

      encryptable_params = {
        data: {
          id: credentials1.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy',
            cleartext_username: 'globi',
            cleartext_password: 'petzi'
          },
          relationships: { folder: { data: { id: new_folder.id, type: 'folders' } } }
        }, id: credentials1.id
      }
      patch :update, params: encryptable_params, xhr: true

      expect(response.status).to be(403)
      expect(errors).to eq(['flashes.admin.admin.no_access'])

      credentials1.reload

      expect do
        credentials1.decrypt(team2_password)
      end.to raise_error(OpenSSL::Cipher::CipherError, 'bad decrypt')

      file_entry = credentials1.file_entries.first
      expect do
        file_entry.decrypt(team2_password)
      end.to raise_error(OpenSSL::Cipher::CipherError, 'bad decrypt')
    end

    it 'cannot set encryptable password and username attributes by params' do
      set_auth_headers

      credentials1 = encryptables(:credentials1)

      encryptable_params = {
        data: {
          id: credentials1.id,
          attributes: {
            username: 'invalid username param',
            password: 'invalid password param'
          },
          relationships: { folder: { data: { id: credentials1.folder_id, type: 'folders' } } }
        }, id: credentials1.id
      }

      patch :update, params: encryptable_params, xhr: true

      credentials1_json_attributes = data['attributes']

      expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
    end

    it 'does not update encryptable when user not in team' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      credentials2 = encryptables(:credentials2)

      encryptable_params = {
        data: {
          id: credentials2.id,
          attributes: {
            name: 'Bob Meyer',
            tag: 'taggy'
          }
        },
        id: credentials2.id
      }

      patch :update, params: encryptable_params, xhr: true

      credentials2.reload

      expect(credentials2.name).to eq 'Twitter Account'
      expect(credentials2.tag).to eq 'tag'
      expect(response).to have_http_status(403)
    end

    it 'updates openshift secret as api user' do
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      teams(:team1).add_user(api_user, team1_password)

      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token

      encryptable = ose_secret

      encryptable_params = {
        data: {
          id: encryptable.id,
          attributes: {
            name: 'updated secret',
            tag: 'taggy'
          },
          relationships: { folder: { data: { id: encryptable.folder_id, type: 'folders' } } }
        }, id: encryptable.id
      }
      patch :update, params: encryptable_params, xhr: true

      encryptable.reload

      encryptable_json_attributes = data['attributes']

      encryptable.decrypt(team1_password)
      expect(encryptable_json_attributes['name']).to eq 'updated secret'

      expect(response).to have_http_status(200)
    end
  end

  context 'POST create' do
    it 'creates a new encryptable if part of team' do
      set_auth_headers

      login_as(:alice)
      folder = folders(:folder1)

      new_encryptable_params = {
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

      post :create, params: new_encryptable_params, xhr: true

      expect(response).to have_http_status(201)
      expect(data['attributes']['name']).to eq 'New Account'
    end

    it 'cannot create a new encryptable if part of team' do
      set_auth_headers

      login_as(:alice)
      folder = folders(:folder2)

      new_encryptable_params = {
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

      post :create, params: new_encryptable_params, xhr: true

      expect(response).to have_http_status(403)
    end

    it 'creates new openshift secret if api user' do
      api_user.update!(valid_until: Time.zone.now + 5.minutes)

      teams(:team1).add_user(api_user, team1_password)

      request.headers['Authorization-User'] = api_user.username
      request.headers['Authorization-Password'] = token

      folder = folders(:folder1)

      new_encryptable_params = {
        data: {
          attributes: {
            name: 'New OSE Secret',
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
        post :create, params: new_encryptable_params, xhr: true
      end.to change { Encryptable::OSESecret.count }.by(1)

      expect(response).to have_http_status(201)
    end

    context 'DELETE destroy' do
      it 'cant destroy an encryptable if not in team' do
        login_as(:alice)

        team2 = teams(:team2)
        encryptable = team2.folders.first.encryptables.first

        expect(team2.teammember?(alice)).to eq false

        expect do
          delete :destroy, params: { id: encryptable.id, folder_id: encryptable.folder.id,
                                     team_id: encryptable.folder.team_id }
        end.to change { Encryptable.count }.by(0)
      end

      it 'can destroy an encryptable if human user is in team' do
        login_as(:bob)

        expect do
          delete :destroy, params: { id: credentials1.id, folder_id: credentials1.folder_id,
                                     team_id: credentials1.folder.team_id }
        end.to change { Encryptable.count }.by(-1)
      end
    end
  end

  private

  def create_ose_secret
    secret = Encryptable::OSESecret.new(name: 'Rails Secret Key Base',
                                        folder: folders(:folder1),
                                        cleartext_ose_secret: example_ose_secret_yaml)
    secret.encrypt(team1_password)
    secret.save!
    secret
  end

  def example_ose_secret_yaml
    Base64.strict_decode64(FixturesHelper.read_encryptable_file('example_secret.secret'))
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
