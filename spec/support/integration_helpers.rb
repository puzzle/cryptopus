# frozen_string_literal: true

module IntegrationHelpers
  module AccountTeamSetupHelper
    def create_team_folder_account(username, user_password = 'password', private = false)
      login_as(username.to_s, user_password)

      # New Team
      team_params = {
        data: {
          attributes: {
            name: 'Web',
            private: private,
            description: 'team_description'
          }
        }
      }
      post api_teams_path, params: team_params

      # New Folder
      team = Team.find_by(name: 'Web')

      folder_params = {
        data: {
          attributes: {
            name: 'Default',
            description: 'yeah'
          },
          relationships: {
            team: {
              data: {
                id: team.id,
                type: 'teams'
              }
            }
          }
        }
      }

      post api_team_folders_path(team.id), params: folder_params

      # New Account
      folder = team.folders.find_by(name: 'Default')
      account_params = {
        data: {
          attributes: {
            type: 'credentials',
            name: 'puzzle',
            folder_id: folder.id,
            description: 'account_description',
            cleartext_username: 'account_username',
            cleartext_password: 'account_password'
          }
        }
      }

      post api_accounts_path, params: account_params

      logout
      folder.accounts.find_by(name: 'puzzle')
    end

    def create_team_folder_account_private(username, user_password = 'password')
      create_team_folder_account(username, user_password, true)
    end

    def create_team(user, teamname, private_team)
      team = Api::Team.create(
        name: teamname,
        description: 'team_description',
        private: private_team
      )

      team_password = cipher.random_key
      crypted_team_password = Symmetric::AES256.encrypt user.public_key, team_password
      Teammember.attr_accessible :team_id, :password
      Teammember.create(team_id: team.id, password: crypted_team_password)
    end

    def create_folder(team, foldername)
      Folder.create(team_id: team.id, name: foldername, description: 'folder_description')
    end
  end

  module DefaultHelper
    def login_as(username, password = 'password')
      post session_path, params: { username: username, password: password }
      follow_redirect!
    end

    def login_as_root
      post session_local_path, params: { username: 'root', password: 'password' }
      follow_redirect!
    end

    def logout
      get session_destroy_path
    end

    def can_access_account(api_account_path, username, user_password = 'password',
                           account_username = 'account_username',
                           account_password = 'account_password')
      username == 'root' ? login_as_root : login_as(username, user_password)
      get api_account_path

      data = JSON.parse(response.body)['data']['attributes']
      expect(data['cleartext_username']).to eq account_username
      expect(data['cleartext_password']).to eq account_password
      logout
    end

    def cannot_access_account(account_path, username, user_password = 'password')
      login_as(username, user_password)
      get account_path
      errors = JSON.parse(response.body)['errors']
      expect(errors.first).to eq('flashes.admin.admin.no_access')
      expect(response.status).to eq 403
      logout
    end

    def expect_ember_frontend
      expect(response.body).to match('<div id="ember-basic-dropdown-wormhole"></div>')
    end
  end
end
