# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
module Api
  module Teams
    class MembersController < ApiController
      self.permitted_attrs = [:user_id]

      # GET /api/teams/:team_id/members
      def index
        authorize team, :list_members?
        super({ render_options: { include: '*', current_user_id: current_user.id } })
      end

      # POST /api/teams/:team_id/members
      def create
        authorize team, :team_member?
        new_member = ::User.find(model_params[:user_id])

        decrypted_team_password = team.decrypt_team_password(current_user, session[:private_key])

        created_member = team.add_user(new_member, decrypted_team_password)

        add_info(t('flashes.api.members.added', username: new_member.username))
        render_json created_member
      end

      # DELETE /api/teams/:team_id/members/:id
      def destroy
        authorize team, :team_member?

        teammember.destroy!

        add_info(t('flashes.api.members.removed', username: username))
        render_json
      end

      private

      def fetch_entries
        team.teammembers.list
      end

      def teammember
        @teammember ||= Teammember.find(params[:id])
      end

      class << self
        def model_class
          Teammember
        end
      end
    end
  end
end
