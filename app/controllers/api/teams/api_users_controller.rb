# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Api
  module Teams
    class ApiUsersController < ApiController

      # GET /api/teams/:team_id/api_users
      def index
        authorize team, :team_member?
        @team_api_users = ::Team::ApiUser.list(current_user, team)
        render_json @team_api_users
      end

      # POST /api/teams/:team_id/api_users
      def create
        authorize team, :team_member?
        plaintext_team_password = team.decrypt_team_password(current_user, session[:private_key])
        added_api_user = team_api_user.enable(plaintext_team_password)
        if added_api_user.present?
          @response_status = :created
          render_json
        else
          render_errors
        end
      end

      # DELETE /api/teams/:team_id/api_users/:id
      def destroy
        authorize team, :team_member?
        if team_api_user.disable
          head 204
        else
          render_errors
        end
      end

      private

      def team_api_user
        api_user = ::User::Api.find(params[:id])
        ::Team::ApiUser.new(api_user, team)
      end
    end
  end
end
