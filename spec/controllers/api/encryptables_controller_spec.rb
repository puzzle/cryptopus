# frozen_string_literal: true

require 'spec_helper'

describe Api::EncryptablesController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:api_user) { bob.api_users.create }
  let(:private_key) { bob.decrypt_private_key('password') }
  let(:nested_models) { ['folder'] }
  # rubocop:disable Metrics/LineLength
  let(:attributes) { %w[name cleartext_password cleartext_username cleartext_pin cleartext_token cleartext_email cleartext_custom_attr] }
  # rubocop:enable Metrics/LineLength
  let(:credentials1) { encryptables(:credentials1) }
  let(:file1) { encryptables(:file1) }
  let(:transferred_file1) { encryptables(:transferredFile1) }


  context 'GET index' do
    it 'returns encryptable with matching name' do
      login_as(:alice)

      get :index, params: { 'q': 'Personal' }, xhr: true

      credentials1_json = data.find { |e| e['id'] == credentials1.id.to_s }
      credentials1_json_attributes = credentials1_json['attributes']
      credentials1_json_relationships = credentials1_json['relationships']

      expect(credentials1_json_attributes['name']).to eq credentials1.name
      expect(credentials1_json['id']).to eq credentials1.id.to_s
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
      expect(credentials1_json_attributes['cleartext_token']).to be_nil
      expect(credentials1_json_attributes['cleartext_pin']).to be_nil
      expect(credentials1_json_attributes['cleartext_email']).to be_nil
      expect(credentials1_json_attributes['cleartext_custom_attr']).to be_nil

      expect(credentials1_json_relationships['folder']['data']['id'])
        .to eq credentials1.folder_id.to_s

      expect_json_object_includes_keys(credentials1_json_attributes, attributes)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns all enncryptables if empty query param given' do
      login_as(:alice)

      get :index, params: { 'q': '' }, xhr: true

      credentials1_json = data.find { |e| e['id'] == credentials1.id.to_s }
      credentials1_json_attributes = credentials1_json['attributes']
      credentials1_json_relationships = credentials1_json['relationships']

      expect(data.count).to eq 2
      expect(credentials1_json_attributes['name']).to eq credentials1.name
      expect(credentials1_json['id']).to eq credentials1.id.to_s
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
      expect(credentials1_json_attributes['cleartext_token']).to be_nil
      expect(credentials1_json_attributes['cleartext_pin']).to be_nil
      expect(credentials1_json_attributes['cleartext_email']).to be_nil
      expect(credentials1_json_attributes['cleartext_custom_attr']).to be_nil
      expect(credentials1_json_relationships['folder']['data']['id'])
        .to eq credentials1.folder_id.to_s

      expect_json_object_includes_keys(credentials1_json_attributes, attributes)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns all encryptables if no query param given' do
      login_as(:alice)

      get :index, xhr: true

      credentials1_json = data.find { |e| e['id'] == credentials1.id.to_s }
      credentials1_json_attributes = credentials1_json['attributes']
      credentials1_json_relationships = credentials1_json['relationships']

      expect(data.count).to eq 2
      expect(credentials1_json_attributes['name']).to eq credentials1.name
      expect(credentials1_json['id']).to eq credentials1.id.to_s
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
      expect(credentials1_json_attributes['cleartext_token']).to be_nil
      expect(credentials1_json_attributes['cleartext_pin']).to be_nil
      expect(credentials1_json_attributes['cleartext_email']).to be_nil
      expect(credentials1_json_attributes['cleartext_custom_attr']).to be_nil
      expect(credentials1_json_relationships['folder']['data']['id'])
        .to eq credentials1.folder_id.to_s

      expect_json_object_includes_keys(credentials1_json_attributes, attributes)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
    end

    it 'returns encryptable for matching tag without cleartext attributes' do
      login_as(:bob)

      get :index, params: { 'tag': 'tag' }, xhr: true

      credentials2_json_attributes = data['attributes']
      credentials2_json_relationships = data['relationships']

      credentials2 = encryptables(:credentials2)

      expect(credentials2_json_attributes['name']).to eq credentials2.name
      expect(data['id']).to eq credentials2.id.to_s
      expect(credentials2_json_attributes['cleartext_username']).to be_nil
      expect(credentials2_json_attributes['cleartext_password']).to be_nil
      expect(credentials2_json_attributes['cleartext_token']).to be_nil
      expect(credentials2_json_attributes['cleartext_pin']).to be_nil
      expect(credentials2_json_attributes['cleartext_email']).to be_nil
      expect(credentials2_json_attributes['cleartext_custom_attr']).to be_nil
      expect(credentials2_json_relationships['folder']['data']['id'])
        .to eq credentials2.folder_id.to_s

      expect_json_object_includes_keys(credentials2_json_attributes, attributes)
      expect_json_object_includes_keys(credentials2_json_relationships, nested_models)
    end

    it 'returns encryptable files for credentials entry' do
      login_as(:alice)

      credentials1 = encryptables(:credentials1)

      get :index, params: { 'credential_id': credentials1.id }, xhr: true

      files_json = data.first
      files_json_attributes = files_json['attributes']

      expect(data.count).to eq 1
      expect(files_json['id']).to eq file1.id.to_s
      expect(files_json_attributes['name']).to eq file1.name
      expect(files_json_attributes['description']).to eq 'One-Time access codes'

      file_attributes = %w[name description]
      expect_json_object_includes_keys(files_json_attributes, file_attributes)
    end

    it 'does not return encryptable file without access' do
      login_as(:alice)

      file = create_file

      get :show, params: { id: file.id }, xhr: true

      expect(response.status).to eq(403)
    end
  end

  context 'GET show' do
    it 'returns decrypted encryptable credentials' do
      login_as(:bob)
      rgx_date = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}).(\d{3})[+-](\d{2}):(\d{2})/

      get :show, params: { id: credentials1 }, xhr: true

      credentials1_json_attributes = data['attributes']
      credentials1_json_relationships = data['relationships']

      expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
      expect(credentials1_json_attributes['cleartext_username']).to eq 'test'
      expect(credentials1_json_attributes['cleartext_password']).to eq 'password'
      expect(credentials1_json_attributes['cleartext_token']).to eq 'testtoken'
      expect(credentials1_json_attributes['cleartext_pin']).to eq 'testpin'
      expect(credentials1_json_attributes['cleartext_email']).to eq 'testemail'
      expect(
        credentials1_json_attributes['cleartext_custom_attr']['label']
      ).to eq 'testcustomattrlabel'
      expect(
        credentials1_json_attributes['cleartext_custom_attr']['value']
      ).to eq 'testcustomattrvalue'
      expect(credentials1_json_attributes['created_at']).to match(rgx_date)
      expect(credentials1_json_attributes['updated_at']).to match(rgx_date)
      expect_json_object_includes_keys(credentials1_json_relationships, nested_models)
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
        expect(credentials1_json_attributes['cleartext_token']).to eq 'testtoken'
        expect(credentials1_json_attributes['cleartext_pin']).to eq 'testpin'
        expect(credentials1_json_attributes['cleartext_email']).to eq 'testemail'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['label']
        ).to eq 'testcustomattrlabel'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['value']
        ).to eq 'testcustomattrvalue'
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
        expect(credentials1_json_attributes['cleartext_token']).to eq 'testtoken'
        expect(credentials1_json_attributes['cleartext_pin']).to eq 'testpin'
        expect(credentials1_json_attributes['cleartext_email']).to eq 'testemail'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['label']
        ).to eq 'testcustomattrlabel'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['value']
        ).to eq 'testcustomattrvalue'
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
        expect(credentials1_json_attributes['cleartext_token']).to eq 'testtoken'
        expect(credentials1_json_attributes['cleartext_pin']).to eq 'testpin'
        expect(credentials1_json_attributes['cleartext_email']).to eq 'testemail'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['label']
        ).to eq 'testcustomattrlabel'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['value']
        ).to eq 'testcustomattrvalue'
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
        expect(credentials1_json_attributes['cleartext_token']).to eq 'testtoken'
        expect(credentials1_json_attributes['cleartext_pin']).to eq 'testpin'
        expect(credentials1_json_attributes['cleartext_email']).to eq 'testemail'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['label']
        ).to eq 'testcustomattrlabel'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['value']
        ).to eq 'testcustomattrvalue'
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
        expect(credentials1_json_attributes['cleartext_token']).to eq 'testtoken'
        expect(credentials1_json_attributes['cleartext_pin']).to eq 'testpin'
        expect(credentials1_json_attributes['cleartext_email']).to eq 'testemail'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['label']
        ).to eq 'testcustomattrlabel'
        expect(
          credentials1_json_attributes['cleartext_custom_attr']['value']
        ).to eq 'testcustomattrvalue'
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
            cleartext_username: 'globi',
            cleartext_password: 'petzi',
            cleartext_token: 'snowli',
            cleartext_pin: 'kuchen',
            cleartext_email: 'findus',
            cleartext_custom_attr: {
              label: 'peterson',
              value: 'salamibrot'
            }
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
      expect(credentials1_json_attributes['cleartext_token']).to eq 'snowli'
      expect(credentials1_json_attributes['cleartext_pin']).to eq 'kuchen'
      expect(credentials1_json_attributes['cleartext_email']).to eq 'findus'
      expect(credentials1_json_attributes['cleartext_custom_attr']['label']).to eq 'peterson'
      expect(credentials1_json_attributes['cleartext_custom_attr']['value']).to eq 'salamibrot'

      expect(response).to have_http_status(200)
    end

    it 'moves encryptable to other team' do
      login_as(:bob)
      request.headers['Authorization-Password'] = Base64.encode64('password')

      credentials1 = encryptables(:credentials1)
      target_folder = folders(:folder2)

      encryptable_params = {
        data: {
          id: credentials1.id,
          attributes: {
            name: 'Bob Meyer',
            cleartext_username: 'globi',
            cleartext_password: 'petzi',
            cleartext_token: 'snowli',
            cleartext_pin: 'kuchen',
            cleartext_email: 'findus',
            cleartext_custom_attr: {
              label: 'peterson',
              value: 'salamibrot'
            }
          },
          relationships: { folder: { data: { id: target_folder.id, type: 'folders' } } }
        }, id: credentials1.id
      }
      patch :update, params: encryptable_params, xhr: true

      credentials1.reload
      credentials1.decrypt(team2_password)

      expect(credentials1.cleartext_username).to eq 'globi'
      expect(credentials1.cleartext_password).to eq 'petzi'
      expect(credentials1.cleartext_token).to eq 'snowli'
      expect(credentials1.cleartext_pin).to eq 'kuchen'
      expect(credentials1.cleartext_email).to eq 'findus'
      expect(credentials1.cleartext_custom_attr[:label]).to eq 'peterson'
      expect(credentials1.cleartext_custom_attr[:value]).to eq 'salamibrot'

      file_entry = credentials1.encryptable_files.first
      file_entry.decrypt(team2_password)
      expect(file_entry.cleartext_file).to match(/Sed modi voluptatem. Maxime qui rerum/)

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
            cleartext_username: 'globi',
            cleartext_password: 'petzi',
            cleartext_token: 'snowli',
            cleartext_pin: 'kuchen',
            cleartext_email: 'findus',
            cleartext_custom_attr: {
              label: 'peterson',
              value: 'salamibrot'
            }
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

      file_entry = credentials1.encryptable_files.first
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
            password: 'invalid password param',
            token: 'invalid token param',
            pin: 'invalid pin param',
            email: 'invalid email param',
            custom_attr: {
              label: 'invalid label param',
              value: 'invalid value param'
            }
          },
          relationships: { folder: { data: { id: credentials1.folder_id, type: 'folders' } } }
        }, id: credentials1.id
      }

      patch :update, params: encryptable_params, xhr: true

      credentials1_json_attributes = data['attributes']

      expect(credentials1_json_attributes['name']).to eq 'Personal Mailbox'
      expect(credentials1_json_attributes['cleartext_username']).to be_nil
      expect(credentials1_json_attributes['cleartext_password']).to be_nil
      expect(credentials1_json_attributes['cleartext_token']).to be_nil
      expect(credentials1_json_attributes['cleartext_pin']).to be_nil
      expect(credentials1_json_attributes['cleartext_email']).to be_nil
      expect(credentials1_json_attributes['cleartext_custom_attr']).to be_nil
    end

    it 'does not update encryptable when user not in team' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      credentials2 = encryptables(:credentials2)

      encryptable_params = {
        data: {
          id: credentials2.id,
          attributes: {
            name: 'Bob Meyer'
          }
        },
        id: credentials2.id
      }

      patch :update, params: encryptable_params, xhr: true

      credentials2.reload

      expect(credentials2.name).to eq 'Twitter Account'
      expect(response).to have_http_status(403)
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
            name: 'New Credentials'
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

    it 'creates new encryptable file' do
      login_as(:bob)

      file = fixture_file_upload('test_file.txt', 'text/plain')
      file_params = {
        credential_id: credentials1.id,
        content_type: 'text/plain',
        file: file,
        description: 'test'
      }

      expect do
        post :create, params: file_params, xhr: true
      end.to change { Encryptable::File.count }.by(1)

      file = Encryptable::File.find_by(name: 'test_file.txt')

      expect(response).to have_http_status(201)
      expect(file.description).to eq file_params[:description]
      file.decrypt(team1_password)
      file_content = fixture_file_upload('test_file.txt', 'text/plain').read
      expect(file.cleartext_file).to eq file_content
    end

    it 'doesnt upload same file twice for credentials' do
      login_as(:bob)

      file = fixture_file_upload('test_file.txt', 'text/plain')
      file_params = {
        credential_id: credentials1.id,
        content_type: 'text/plain',
        file: file,
        description: 'test'
      }

      expect do
        post :create, params: file_params, xhr: true
      end.to change { Encryptable::File.count }.by(1)

      expect(response).to have_http_status(201)

      expect do
        post :create, params: file_params, xhr: true
      end.to change { Encryptable::File.count }.by(0)

      expect(response).to have_http_status(422)

      expect(errors.first['detail']).to eq 'File has already been taken'
    end

    it 'does not upload empty file' do
      login_as(:bob)

      file = fixture_file_upload('empty.txt', 'text/plain')
      file_params = {
        credential_id: credentials1.id,
        content_type: 'text/plain',
        file: file,
        description: 'test'
      }

      expect do
        post :create, params: file_params, xhr: true
      end.to change { Encryptable::File.count }.by(0)

      expect(response).to have_http_status(422)

      expect(errors.first['detail']).to eq 'File is not allowed to be blank'
    end
  end

  context 'DELETE destroy' do
    it 'cant destroy an encryptable if not in team' do
      login_as(:alice)

      team2 = teams(:team2)
      encryptable = team2.folders.first.encryptables.first

      expect(team2.teammember?(alice)).to eq false

      expect do
        delete :destroy, params: { id: encryptable.id }
      end.to change { Encryptable.count }.by(0)
    end

    it 'can destroy an encryptable entry if human user is in team' do
      login_as(:bob)

      expect do
        delete :destroy, params: { id: encryptables(:credentials2).id }
      end.to change { Encryptable::Credentials.count }.by(-1)
    end
  end

  context 'transfer' do
    it 'alice receives file from bob' do
      login_as(:bob)

      filename = 'test_file.txt'
      inbox_folder_receiver = alice.inbox_folder

      file = Encryptable::File.new(folder: inbox_folder_receiver,
                                   description: 'test',
                                   name: filename,
                                   content_type: 'text/plain',
                                   cleartext_file: 'certificate')

      EncryptableTransfer.new.transfer(file, alice, bob)

      login_as(:alice)

      shared_file = alice.inbox_folder.encryptables.last

      get :show, params: { id: shared_file.id }, xhr: true

      expect(response).to have_http_status(200)

      alice_private_key = alice.decrypt_private_key('password')
      personal_team_password = alice.personal_team.decrypt_team_password(alice, alice_private_key)

      received_file = Encryptable.find(shared_file.id)
      received_file.decrypt(personal_team_password)

      expect(received_file.encrypted_transfer_password).to eq(nil)
      expect(received_file.sender_id).to eq(bob.id)
      expect(received_file.name).to eq('test_file.txt')
      expect(received_file.description).to eq('test')
      expect(received_file.content_type).to eq('text/plain')
      expect(received_file.folder_id).to eq(alice.inbox_folder.id)
      expect(received_file.cleartext_file).to eq('certificate')
    end

    it 'download transferred encryptable' do
      login_as(:bob)

      encryptable_file = prepare_transferred_encryptable

      login_as(:alice)

      expect(controller).to receive(:send_file).exactly(:once)

      get :show, params: { id: encryptable_file.id }, xhr: true
    end

    it 'displays transferred encryptable and dont download it' do
      login_as(:bob)

      encryptable_file = prepare_transferred_encryptable

      login_as(:alice)

      expect(controller).not_to receive(:send_file)
      expect_any_instance_of(CrudController).to receive(:render_entry).exactly(:once)

      get :show, params: { id: encryptable_file.id,
                           encryptable: ActionController::Parameters.new({
                                                                           test: 1
                                                                         }).permit! }, xhr: true
    end
  end

  private

  def create_file
    file = Encryptable::File.new(name: 'file',
                                 cleartext_file: file_fixture('test_file.txt').read,
                                 credential_id: encryptables(:credentials2).id,
                                 content_type: 'text/plain')
    file.encrypt(team2_password)
    file.save!
    file
  end

  def prepare_transferred_encryptable
    encryptable_file = Encryptable::File.new(name: 'file',
                                             cleartext_file: file_fixture('test_file.txt').read,
                                             content_type: 'text/plain')

    transfer_password = Crypto::Symmetric::Aes256.random_key

    encryptable_file.encrypt(transfer_password)

    encrypted_transfer_password = Crypto::Rsa.encrypt(
      transfer_password,
      alice.public_key
    )
    encryptable_file.encrypted_transfer_password = Base64.encode64(encrypted_transfer_password)
    encryptable_file.sender_id = bob.id
    encryptable_file.folder = alice.inbox_folder
    encryptable_file.save!

    encryptable_file
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
