# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Team::MembersController < ApiController

  def index
    skip_policy_scope
    authorize team, :team_member?
    members = TeamPolicy::Scope.new(current_user, team).resolve_members
    render_json members
  end

  def candidates
    authorize team, :team_member?
    candidates = team.member_candidates
    render_json candidates
  end

  def create
    authorize team, :add_member?
    new_member = User.find(params[:user_id])

    decrypted_team_password = team.decrypt_team_password(current_user, session[:private_key])

    team.add_user(new_member, decrypted_team_password)

    add_info(t('flashes.api.members.added', username: new_member.username))
    render_json ''
  end

  def destroy
    authorize team, :remove_member?
    teammember.destroy!

    remove_api_users(teammember.user) if teammember.user.type == 'User::Human'

    username = User.find(params[:id]).username
    add_info(t('flashes.api.members.removed', username: username))
    render_json ''
  end

  private

  def remove_api_users(user)
    user.api_users.each do |api_user|
      team_api_user = create_team_api_user(api_user)
      if team_api_user.enabled?
        team_api_user.disable
      end
    end
  end

  def create_team_api_user(api_user)
    Team::ApiUser.new(api_user, team)
  end

  def teammember
    @teammember ||= team.teammembers.find_by(user_id: params[:id])
  end
end
