# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::TeamsController < ApiController

  self.permitted_attrs = [:name, :description, :private]

  def self.policy_class
    TeamPolicy
  end

  # GET /api/teams
  def index
    if team_id_present?
      authorize fetch_entries.first, :team_member?
    else
      authorize ::Team
    end
    super(render_options: { include: '**' })
  end

  # POST /api/teams
  def create
    team = Team.create(current_user, model_params)
    authorize team
    team.save
    add_info(t('flashes.teams.created'))

    render_json team
  end

  private

  def fetch_entries
    @entries ||= ::Teams::FilteredList.new(current_user, params).fetch_entries
  end

  def user
    @user ||= User.find(params['user_id'])
  end

  def team
    @team ||= ::Team.find(params['id'])
  end

  def team_id_present?
    params['team_id'].present?
  end

  class << self
    def model_class
      Team
    end
  end
end
