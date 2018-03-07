# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::TeamsController < ApiController

  def self.policy_class
    TeamPolicy
  end

  def index
    teams = policy_scope(Team)
    render_json find_teams(teams)
  rescue ActionController::ParameterMissing
    render_json
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

  def find_teams(teams)
    if query_param.present?
      teams = finder(teams, query_param).apply
    end
    teams
  end

  def finder(teams, query)
    Finders::TeamsFinder.new(teams, query)
  end

  def query_param
    params[:q]
  end
end
