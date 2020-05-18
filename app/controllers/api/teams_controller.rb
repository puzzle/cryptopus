# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::TeamsController < ApiController

  self.permitted_attrs = [:name, :description]

  def self.policy_class
    TeamPolicy
  end

  # GET /api/teams
  def index
    authorize ::Team
    teams = current_user.teams
    render_json find_teams(teams)
  end

  # GET /api/teams/:id
  def show
    authorize team
    render_json team
  end

  # PATCH /api/teams/:id
  def update
    authorize team
    team.attributes = model_params
    team.save!
    render_json
  end

  # GET /api/teams/last_teammember_teams
  def last_teammember_teams
    authorize ::Team, :last_teammember_teams?
    teams = user.last_teammember_teams
    render_json teams
  end

  # DELETE /api/teams/:id
  def destroy
    authorize team
    team.destroy
    render_json
  end

  private

  def user
    @user ||= User.find(params['user_id'])
  end

  def team
    @team ||= ::Team.find(params['id'])
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
