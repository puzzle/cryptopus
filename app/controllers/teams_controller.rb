# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class TeamsController < ApplicationController
  self.permitted_attrs = [:name, :private, :description]

  helper_method :team

  # GET /teams
  def index
    authorize Team
    @teams = current_user.teams

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # GET /teams/1
  def show
    authorize team, :team_member?
    @groups = team.groups
    groups_breadcrumbs

    teammembers = team.teammembers.list
    @teammembers = teammembers.includes(:user).sort_by { |tm| tm.label.downcase }

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # GET /teams/new
  def new
    @team = Team.new
    authorize @team

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams
  def create
    respond_to do |format|
      team = Team.create(current_user, model_params)
      authorize team
      if team.valid?
        flash[:notice] = t('flashes.teams.created')
        format.html { redirect_to(teams_url) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # GET /teams/1/edit
  def edit
    authorize team
    add_breadcrumb t('teams.title'), :teams_path
    add_breadcrumb team.label
  end

  # PUT /teams/1
  def update
    authorize team
    add_breadcrumb t('teams.title'), :teams_path
    respond_to do |format|
      if team.update!(model_params)
        flash[:notice] = t('flashes.teams.updated')
        format.html { redirect_to(teams_url) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1
  def destroy
    authorize team
    team.destroy
    flash[:notice] = t('flashes.teams.deleted')
    redirect_to teams_path
  end

  private

  def groups_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path

    add_breadcrumb team.label if action_name == 'show'

    if action_name == 'edit'
      add_breadcrumb team.label, :team_group_path
      add_breadcrumb @group.label
    end
  end

  def team
    @team ||= Team.find(params[:id])
  end
end
