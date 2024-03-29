# frozen_string_literal: true

require 'spec_helper'

describe Api::TeamsController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:alice) { users(:alice) }
  let(:team1) { teams(:team1) }
  let(:team2) { teams(:team2) }
  let(:personal_team_bob) { teams(:personal_team_bob) }
  let!(:team3) { Fabricate(:non_private_team) }
  let!(:team4) { Fabricate(:non_private_team) }
  let(:bobs_private_key) { bob.decrypt_private_key('password') }
  let!(:team3_user) { team3.teammembers.first.user }
  let(:test_file) { FixturesHelper.read_file('test_file.txt') }

  context 'GET index' do
    it 'should get team for search term' do
      login_as(:bob)

      get :index, params: { q: 'non' }, xhr: true

      expect(data.size).to be(0)
      expect(included).to be(nil)
    end

    it 'raises invalid argument error if query param blank' do
      login_as(:bob)

      get :index, params: { q: '' }, xhr: true

      expect(response).to have_http_status 400
      expect(errors).to eq(['flashes.api.errors.bad_request'])
    end

    it 'returns all teams and its folders if no query nor id is given' do
      login_as(:bob)

      get :index, xhr: true

      expect(data.size).to be(3)
      expect(included.size).to be(5)

      data.each do |team|
        expect(team['type']).to eq('teams')
        expect(team['attributes']['personal_team']).to eq(false) unless team.first
      end

      included_folders = included.select { |e| e['type'] == 'folders' }
      expect(included_folders.size).to be(5)

      included_types = json['included'].map { |e| e['type'] }
      expect(included_types).not_to include('encryptable_credentials')
    end

    it 'raises error if team_id doesnt exist' do
      login_as(:alice)

      inexistent_id = 11111111

      get :index, params: { team_id: inexistent_id }, xhr: true

      expect(response).to have_http_status 404
      expect(errors).to eq(['flashes.api.errors.record_not_found'])
    end

    it 'returns a single team if one team_id is given' do
      login_as(:bob)

      get :index, params: { team_id: team1.id }, xhr: true

      expect(response.status).to be(200)

      attributes = data.first['attributes']

      included_types = json['included'].map { |e| e['type'] }

      expect(included_types).to include('folders')
      expect(included_types).to include('encryptable_credentials')

      expect(attributes['name']).to eq team1.name
      expect(attributes['description']).to eq team1.description

      expect(attributes['name']).not_to eq team3.name
      expect(attributes['description']).not_to eq team3.description

      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(4)
      expect(folder_relationships_length).to be(3)
    end

    it 'returns bobs favourite teams' do
      login_as(:bob)

      get :index, params: { favourite: true }, xhr: true

      expect(response.status).to be(200)

      expect(data.size).to be(2)
      attributes = data.second['attributes']

      included_types = json['included'].map { |e| e['type'] }

      expect(included_types).to include('folders')
      expect(included_types).not_to include('encryptable_credentials')
      expect(included_types).not_to include('encryptable_file')

      expect(attributes['name']).to eq team1.name
      expect(attributes['description']).to be_nil

      folder_relationships_length = data.second['relationships']['folders']['data'].size

      expect(included.size).to be(4)
      expect(folder_relationships_length).to be(3)

    end

    it 'doesnt return team if not member' do
      login_as(:alice)

      get :index, params: { team_id: team2.id }, xhr: true

      expect(response.status).to be(403)
      expect(errors).to eq(['flashes.admin.admin.no_access'])
      expect(data).to be(nil)
      expect(included).to be(nil)
    end

    it 'doesnt return team by query if not team member' do
      login_as(:alice)

      get :index, params: { q: team2.name }, xhr: true

      expect(response.status).to be(200)

      expect(data).to eq([])
      expect(included).to be(nil)

    end

    it 'returns teams, folders and encryptables for query, in order from name' do
      login_as(:bob)

      folder1 = folders(:folder1)
      folder2 = folders(:folder2)

      credentials1 = encryptables(:credentials1)
      credentials2 = encryptables(:credentials2)
      credentials3 = Encryptable::Credentials.create(
        name: 'All twitter',
        description: 'My twitter account',
        folder: folder2
      )

      get :index, params: { q: 'twitter' }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      attributes_first_team = data.first['attributes']

      expect(attributes_first_team['name']).to eq team2.name
      expect(attributes_first_team['description']).to eq team2.description

      folders = included.select { |element| element['type'] == 'folders' }
      encryptables = included.select { |element| element['type'] == 'encryptable_credentials' }

      expect(folders.first['attributes']['name']).to eq(folder2.name)
      expect(folders).not_to include(folder1.name)

      expect(encryptables.first['attributes']['name']).to eq(credentials3.name)
      expect(encryptables.second['attributes']['name']).to eq(credentials2.name)
      expect(encryptables).not_to include(credentials1.name)
      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(3)
      expect(folder_relationships_length).to be(1)
    end

    ## TODO: Re-enable after fixing encryptables ordering, see https://github.com/puzzle/cryptopus/issues/760
    xit 'returns encryptable files for team_id, in order from created_at' do
      inbox_folder_receiver = alice.inbox_folder
      personal_team_alice = teams(:personal_team_alice)

      filename1 = 'other_file.txt'
      file = Encryptable::File.new(folder: inbox_folder_receiver,
                                   description: 'Other file for alice',
                                   name: filename1,
                                   content_type: 'text/plain',
                                   created_at: DateTime.now - 3.years,
                                   cleartext_file: 'certificate1')
      EncryptableTransfer.new.transfer(file, alice, bob)

      filename2 = 'test_file.txt'
      file = Encryptable::File.new(folder: inbox_folder_receiver,
                                   description: 'Test file',
                                   name: filename2,
                                   content_type: 'text/plain',
                                   created_at: DateTime.now,
                                   cleartext_file: 'certificate2')
      EncryptableTransfer.new.transfer(file, alice, bob)

      login_as(:alice)

      get :index, params: { team_id: personal_team_alice.id }, xhr: true

      expect(data.count).to eq(1)

      folders = included.select { |element| element['type'] == 'folders' }
      encryptables = included.select { |element| element['type'] == 'encryptable_files' }

      expect(folders.first['attributes']['name']).to eq('inbox')

      expect(encryptables.first['attributes']['name']).to eq(filename2)
      expect(encryptables.first['attributes']['name']).not_to eq(filename1)
      expect(encryptables.last['attributes']['name']).to eq(filename1)
      expect(encryptables.last['attributes']['name']).not_to eq(filename2)

      expect(encryptables.count).to be(2)
      expect(included.size).to be(3)
    end

    it 'returns sender_name if transferred encryptable' do
      login_as(:alice)

      filename = 'test_file.txt'
      inbox_folder_receiver = bob.inbox_folder

      file = Encryptable::File.new(folder: inbox_folder_receiver,
                                   description: 'test',
                                   name: filename,
                                   content_type: 'text/plain',
                                   cleartext_file: 'certificate')

      EncryptableTransfer.new.transfer(file, bob, alice)

      login_as(:bob)
      get :index, params: { team_id: personal_team_bob.id }, xhr: true

      expect(included.last['attributes']).to include('sender_name')
      expect(included.last['attributes']['sender_name']).to eq(alice.label)
      expect(included.last['attributes']['name']).to eq(file.name)
      expect(included.last['attributes']['description']).to eq('test')
    end

    it 'does not return sender_name if not transferred encryptable' do
      login_as(:bob)

      get :index, params: { team_id: team1.id }, xhr: true

      expect(response.status).to be(200)
      expect(included.last['attributes']).not_to include('sender_name')
    end

    it 'filters by team name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      get :index, params: { q: team3.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      attributes_team = data.first['attributes']
      team3_attributes = team3.attributes
      team3_attributes['favourised'] = false
      team3_attributes['deletable'] = false
      team3_attributes['personal_team'] = false
      team3_attributes['password_bitsize'] = 256
      expect(team3_attributes).to include(attributes_team)
      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(2)
      expect(folder_relationships_length).to be(1)
    end

    it 'filters by folder name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      folder = team3.folders.first

      get :index, params: { q: folder.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      relationships_folder_team = data.first['relationships']['folders']['data'].first

      expect(relationships_folder_team['id'].to_i).to eq folder.id
      expect(relationships_folder_team['type']).to eq 'folders'
      folder_relationships_length = data.first['relationships']['folders']['data'].size

      expect(included.size).to be(2)
      expect(folder_relationships_length).to be(1)
    end

    it 'filters by encryptable name' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      folder = team3.folders.first
      credential = folder.encryptables.first

      get :index, params: { q: credential.name }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      included_encryptable = included.second

      expect(included_encryptable['id'].to_i).to eq credential.id
      expect(included_encryptable['attributes']['name']).to eq credential.name
      expect(included_encryptable['attributes']['description']).to eq credential.description
    end

    it 'filters by encryptable description' do
      add_bob_to_team(team3, team3_user)
      login_as(:bob)

      credentials1 = encryptables(:credentials1)

      get :index, params: { q: credentials1.description }, xhr: true

      expect(data.count).to eq(1)
      expect(response.status).to be(200)

      included_encryptable = included.second

      expect(included_encryptable['id'].to_i).to eq credentials1.id
      expect(included_encryptable['attributes']['name']).to eq credentials1.name
      expect(included_encryptable['attributes']['description']).to eq credentials1.description
    end

    context 'with only_teammember_user_id param' do
      let(:team) { Fabricate(:non_private_team) }
      let(:user) { team.teammembers.first.user }
      let(:personal_team) { user.personal_team }

      context 'as admin' do
        before { login_as(:admin) }

        it 'returns personal team' do
          get :index, params: { only_teammember_user_id: user.id }

          team_data = data.first
          team_attributes = team_data['attributes']

          expect(team_data['id'].to_i).to eq(personal_team.id)
          expect(team_attributes['name']).to eq(personal_team.name)
          expect(team_attributes['description']).to be_nil

          expect(response).to have_http_status(200)
        end
      end

      context 'as conf_admin' do
        before { login_as(:tux) }

        it 'returns personal team' do
          get :index, params: { only_teammember_user_id: user.id }

          team_data = data.first
          team_attributes = team_data['attributes']

          expect(team_data['id'].to_i).to eq(personal_team.id)
          expect(team_attributes['name']).to eq(personal_team.name)
          expect(team_attributes['description']).to be_nil

          expect(response).to have_http_status(200)
        end
      end

      context 'as user' do
        before { login_as(:bob) }

        it 'is not unauthorized' do
          get :index, params: { only_teammember_user_id: user.id }

          expect(response).to have_http_status(403)
        end
      end
    end

    context 'Recrypt' do
      it 'triggers team recrypt if latest algorithm is not applied on team' do
        admin = users(:admin)
        login_as(:admin)
        api_user = admin.api_users.create!

        stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256')

        team = Fabricate(:non_private_team)

        # Add api user to team
        admins_private_key = admin.decrypt_private_key('password')
        plaintext_team_password = team.decrypt_team_password(admin, admins_private_key)
        team.add_user(api_user, plaintext_team_password)

        expect(team.encryption_algorithm).to eq('AES256')

        stub_const('::Crypto::Symmetric::LATEST_ALGORITHM', 'AES256IV')

        get :index, params: { team_id: team.id }, xhr: true

        expect(response.status).to be(200)

        team.reload
        expect(team.encryption_algorithm).to eq('AES256IV')
      end

      it 'does not recrypt if latest algorithm' do
        login_as(:bob)

        get :index, params: { team_id: team1.id }, xhr: true

        expect(team1.encryption_algorithm).to eq('AES256IV')

        expect(response.status).to be(200)

        team1.reload
        expect(team1.encryption_algorithm).to eq('AES256IV')
      end
    end

    context 'Receive transferred encryptables' do
      it 'Receive method gets called to encrypt transferred encryptable' do
        login_as(:bob)

        Fabricate(
          :transferred_file,
          id_sender: alice.id,
          receiver_inbox_folder: bob.inbox_folder,
          receiver_pk: bob.public_key,
          encryption_algorithm: Crypto::Symmetric::Aes256
        )

        expect_any_instance_of(EncryptableTransfer)
          .to receive(:receive)
          .exactly(1).times
          .and_return(nil)

        default_folder = Folder.new(name: 'default', team: personal_team_bob)

        personal_team_bob.folders = [default_folder, bob.inbox_folder]

        personal_team_bob.encryption_algorithm = 'AES256'
        personal_team_bob.save!

        expect do
          get :index, params: { team_id: personal_team_bob.id }, xhr: true
        end.to raise_error(RuntimeError)

      end

      it 'Receive method to encrypt transferred encryptable dont get called on recent algorithm' do
        login_as(:bob)

        Fabricate(
          :transferred_file,
          id_sender: alice.id,
          receiver_inbox_folder: bob.inbox_folder,
          receiver_pk: bob.public_key,
          encryption_algorithm: Crypto::Symmetric::Aes256iv
        )

        expect_any_instance_of(EncryptableTransfer)
          .not_to receive(:receive)
          .and_return(nil)

        default_folder = Folder.new(name: 'default', team: personal_team_bob)

        personal_team_bob.folders = [default_folder, bob.inbox_folder]

        get :index, params: { team_id: personal_team_bob.id }, xhr: true
      end

      it 'It does not receive encryptables in personal team if they are not transferred' do
        login_as(:bob)

        params = {}
        params[:name] = 'Shopping Account'
        params[:folder_id] = bob.inbox_folder.id
        params[:type] = 'Encryptable::Credentials'
        params[:cleartext_username] = 'username'
        Encryptable::Credentials.new(params)

        expect_any_instance_of(EncryptableTransfer)
          .not_to receive(:receive)
          .exactly(1).times
          .and_return(nil)

        default_folder = Folder.new(name: 'default', team: personal_team_bob)

        personal_team_bob.folders = [default_folder, bob.inbox_folder]

        get :index, params: { team_id: personal_team_bob.id }, xhr: true
      end
    end
  end

  context 'PUT update' do
    it 'updates team with valid params structure' do
      set_auth_headers

      update_params = {
        data: {
          id: team1.id,
          attributes: {
            name: 'Team Bob',
            description: 'yeah, my own team'
          }
        }, id: team1.id
      }

      patch :update, params: update_params, xhr: true

      team1.reload

      expect(team1.name).to eq(update_params[:data][:attributes][:name])
      expect(team1.description).to eq(update_params[:data][:attributes][:description])

      expect(response).to have_http_status(200)
    end

    it 'does not update team when user not teammember' do
      request.headers['Authorization-User'] = alice.username
      request.headers['Authorization-Password'] = Base64.encode64('password')

      team_params =
        {
          id: team2.id,
          team:
            {
              name: 'Team Alice',
              description: 'yeah, i wanna steal that team'
            }
        }
      patch :update, params: team_params, xhr: true

      team2.reload

      expect(team2.name).to eq('team2')
      expect(team2.description).to eq('public')

      expect(response).to have_http_status(403)
    end

    it 'cannot enable private on existing team' do
      set_auth_headers

      expect(team1).to_not be_private

      update_params = {
        data: {
          id: team1.id,
          attributes: {
            private: true
          }
        }, id: team1.id
      }

      patch :update, params: update_params, xhr: true

      team1.reload

      expect(team1).to_not be_private

      expect(response).to have_http_status(200)
    end

    it 'cannot disable private on existing team' do
      set_auth_headers

      team_params = { name: 'foo', private: true }
      new_team = Team::Shared.create(users(:bob), team_params)

      update_params = {
        data: {
          id: new_team.id,
          attributes: {
            private: false
          }
        }, id: new_team.id
      }

      patch :update, params: update_params, xhr: true

      new_team.reload

      expect(new_team).to be_private

      expect(response).to have_http_status(200)
    end

  end

  context 'POST create' do
    it 'creates new team as user' do
      login_as(:bob)

      team_params = {
        data: {
          attributes: {
            name: 'foo',
            private: false,
            description: 'foo foo'
          }
        }
      }

      expect do
        post :create, params: team_params, xhr: true
      end.to change { Team.count }.by(1)

      team = Team.find_by(name: team_params[:data][:attributes][:name])

      expect(team.description).to eq(team_params[:data][:attributes][:description])
      expect(team.private).to be team_params[:data][:attributes][:private]

      expect(response).to have_http_status(201)
    end

    it 'creates new private team as user' do
      login_as(:bob)

      team_params = {
        data: {
          attributes: {
            name: 'foo',
            private: true,
            description: 'foo foo'
          }
        }
      }

      expect do
        post :create, params: team_params, xhr: true
        expect(response).to have_http_status(201)
      end.to change { Team.count }.by(1)

      team = Team.find_by(name: team_params[:data][:attributes][:name])

      expect(team.description).to eq(team_params[:data][:attributes][:description])
      expect(team.private).to be team_params[:data][:attributes][:private]

      expect(response).to have_http_status(201)
    end

  end

  context 'DELETE destroy' do
    it 'destroys team' do
      login_as(:admin)
      team = Fabricate(:private_team)

      expect do
        delete :destroy, params: { id: team.id }
      end.to change { Team.count }.by(-1)
    end

    it 'cannot delete team if not admin' do
      login_as(:bob)
      soloteam = Fabricate(:private_team)
      user = soloteam.teammembers.first.user

      expect do
        delete :destroy, params: { id: soloteam.id }
      end.to change { Team.count }.by(0)

      expect(errors).to eq(['flashes.admin.admin.no_access'])
      expect(response).to have_http_status 403
      expect(user.only_teammember_teams).to be_present
    end

    it 'cannot delete team as normal user if not in team' do
      login_as(:bob)

      teammembers(:team1_bob).delete

      expect do
        delete :destroy, params: { id: teams(:team1).id }
      end.to change { Team.count }.by(0)

      expect(response).to have_http_status 403
    end


  end

  private

  def add_bob_to_team(team, user)
    decrypted_team_password = team.decrypt_team_password(user, user.decrypt_private_key('password'))
    team.add_user(bob, decrypted_team_password)
  end

  def set_auth_headers
    request.headers['Authorization-User'] = bob.username
    request.headers['Authorization-Password'] = Base64.encode64('password')
  end

end
