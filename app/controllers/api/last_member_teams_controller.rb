# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::LastMemberTeamsController < ApiController

  def self.policy_class
    TeamPolicy
  end

  # GET /api/teams/last_member_teams
  def index
    authorize ::Team, :last_teammember_teams?
    teams = user.last_teammember_teams
    render_json teams
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

end
