# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::TeamsController < ApiController

  def index
    teams = policy_scope Team
    render_json teams
  end

  def last_teammember_teams
    teams = user.last_teammember_teams
    authorize teams
    render_json teams
  end

  def destroy
    authorize team
    team.destroy
    render_json ''
  end

  private

  def user
    @user ||= User.find(params['user_id'])
  end

  def team
    @team ||= Team.find(params['id'])
  end
end
