# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Api
  module Teams
    class ApiUsersController < ApiController

      # GET /api/api_users
      def index
        authorize team, :team_member?
        @team_api_users = Team::ApiUser.list(current_user, team)
        render_json @team_api_users
      end

      # POST /api/api_users
      def create
        authorize team, :team_member?
        plaintext_team_password = team.decrypt_team_password(current_user, session[:private_key])
        team_api_user.enable(plaintext_team_password)
        render_json
      end

      # DELETE /api/api_users/:id
      def destroy
        authorize team, :team_member?
        team_api_user.disable
        render_json
      end

      private

      def team_api_user
        api_user = ::User::Api.find(params[:id])
        Team::ApiUser.new(api_user, team)
      end
    end
  end
end