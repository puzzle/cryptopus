# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class TeamsController < ApplicationController
  helper_method :team

  # GET /teams
  def index
    @teams = policy_scope Team

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
      team = Team.create(current_user, team_params)
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
      if team.update_attributes(team_params)
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

  def team_params
    params.require(:team).permit(:name, :private, :description)
  end

  def team
    @team ||= Team.find(params[:id])
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: 'pundit', default: :default
    redirect_to teams_path
  end
end
