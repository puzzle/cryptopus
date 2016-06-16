# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Team::MembersController < ApiController

  def index
    members = team.teammembers.list
    render json: members
  end

  def candidates
    candidates = team.member_candidates
    render json: candidates
  end

  def create
    new_member = User.find(params[:user_id])

    decrypted_team_password = team.decrypt_team_password(current_user, session[:private_key])

    team.add_user(new_member, decrypted_team_password)

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
