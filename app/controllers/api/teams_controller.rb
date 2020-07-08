# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::TeamsController < ApiController
  before_action :assert_valid_query, if: -> { params.key? :q }, only: [:index]
  before_action :assert_valid_team, if: -> { params.key? :team_id }, only: [:index]

  self.permitted_attrs = [:name, :description, :private]

  def self.policy_class
    TeamPolicy
  end

  # GET /api/teams
  def index
    if params['team_id'].present?
      authorize fetch_entries.first, :team_member?
    else
      authorize ::Team
    end
    super(render_options: render_options)
  end

  private

  def build_entry
    instance_variable_set(:"@#{ivar_name}",
                          Team.create(current_user, model_params))
  end

  def assert_valid_query
    raise ArgumentError, 'invalid length of query' if query.strip.blank?
  end

  def assert_valid_team
    raise ActiveRecord::RecordNotFound if team_id.blank?
  end

  def query
    params[:q]
  end

  def team_id
    params[:team_id]
  end

  def fetch_entries
    @entries ||= ::Teams::FilteredList.new(current_user, params).fetch_entries
  end

  def user
    @user ||= User.find(params['user_id'])
  end

  def team
    @team ||= ::Team.find(params['id'])
  end

  def render_options
    fetch_entries == current_user.teams ? { include: '*' } : { include: '**' }
  end
end
