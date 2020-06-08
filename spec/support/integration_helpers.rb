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

      post "/api/teams/#{team.id}/folders", params: folder_params

      # New Account
      folder = team.folders.find_by(name: 'Default')
      account_path = api_accounts_path

      account_params = {
        data: {
          attributes: {
            accountname: 'puzzle',
            folder_id: folder.id,
            description: 'account_description',
            cleartext_username: 'account_username',
            cleartext_password: 'account_password'
          }
        }
      }

      post account_path, params: account_params

      logout
      folder.accounts.find_by(accountname: 'puzzle')
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
      crypted_team_password = CryptUtils.encrypt_blob user.public_key, team_password
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

    def logout
      get session_destroy_path
    end

    def can_access_account(account_path, username, user_password = 'password',
                           account_username = 'account_username',
                           account_password = 'account_password')
      login_as(username, user_password)
      get account_path
      expect(response.body)
        .to match(/input .* id='cleartext_username' .* value='#{account_username}'/)
      expect(response.body)
        .to match(/input .* id='cleartext_password' .* value='#{account_password}'/)
      logout
    end

    def cannot_access_account(account_path, username, user_password = 'password')
      login_as(username, user_password)
      get account_path
      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
      logout
    end
  end
end
