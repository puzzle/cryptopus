# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
module Api
  module Teams
    class MembersController < ApiController
      self.permitted_attrs = [:user_id]
      self.custom_model_class = Teammember

      # GET /api/teams/:team_id/members
      def index
        authorize team, :list_members?
        render({ json: fetch_entries,
                 each_serializer: list_serializer,
                 root: model_root_key.pluralize }
          .merge(include: '*', current_user_id: current_user.id))
      end

      # POST /api/teams/:team_id/members
      def create
        authorize team.teammembers.new, :create?
        new_member = ::User.find(model_params[:user_id])
        decrypted_team_password = team.decrypt_team_password(current_user, session[:private_key])
        created_member = team.add_user(new_member, decrypted_team_password)
        if created_member.present?
          @response_status = :created
          render_json created_member
        else
          render_errors
        end
      end

      # DELETE /api/teams/:team_id/members/:id
      def destroy
        authorize teammember, :destroy?
        if teammember.destroy
          @response_status = 204
          add_info(t('flashes.api.members.removed'))
          render_json
        else
          render_errors
        end
      end

      private

      def fetch_entries
        team.teammembers.list
      end

      def teammember
        @teammember ||= Teammember.find(params[:id])
      end
    end
  end
end
