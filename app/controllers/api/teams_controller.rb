# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

# As a autoload error often occurs, the file needs to be included separately
require_relative '../../presenters/teams/filtered_list'

class Api::TeamsController < ApiController
  before_action :assert_valid_query, if: -> { params.key? :q }, only: [:index]
  before_action :assert_valid_team, if: -> { params.key? :team_id }, only: [:index]

  self.permitted_attrs = [:name, :description, :private]

  # GET /api/teams
  def index
    if params['team_id'].present?
      authorize fetch_entries.first, :team_member?
    elsif params['only_teammember_user_id'].present?
      authorize ::Team, :only_teammember?
    else
      authorize ::Team
    end
    super(render_options: render_options)
  end

  private

  def build_entry
    instance_variable_set(:"@#{ivar_name}",
                          Team::Shared.create(current_user, model_params))
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
    @entries ||= Teams::FilteredList.new(current_user, params).fetch_entries
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
