# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Team::ApiUsersController < ApiController

  def index
    skip_policy_scope
    authorize team, :team_member?
    @team_api_users = Team::ApiUser.list(current_user, team)
    render_json @team_api_users
  end

  def create
    authorize team, :team_member?
    plaintext_team_password = team.decrypt_team_password(current_user, session[:private_key])
    team_api_user.enable(plaintext_team_password)
    render_json
  end

  def destroy
    authorize team, :team_member?
    team_api_user.disable
  end

  private

  def team_api_user
    api_user = User::Api.find_by_id(params[:id])
    Team::ApiUser.new(api_user, team)
  end
end
