# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Team::MembersController < ApiController

  def index
    members = team.teammembers
    render json: members
  end

  def candidates
    candidates = team.member_candidates
    render json: candidates
  end

  def create
    team = Team.find(params[:team_id])
    user = User.find(params[:user_id])
    private_key = session[:private_key]
    team_password = team.teammember(current_user).password
    decrypted_team_password = CryptUtils.decrypt_team_password(team_password, private_key)

    team.add_user(user, decrypted_team_password)

    render json: ''
  end

  def destroy
    team.teammembers.find_by(user_id: params[:id]).destroy!
    render json: ''
  end

  private

  def team
    @team ||= ::Team.find(params[:team_id])
  end

end
