# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class GroupsController < ApplicationController
  helper_method :team

  # GET /teams/1/groups
  def index
    groups_breadcrumbs

    @groups = GroupPolicy::Scope.new(current_user, team).resolve

    teammembers = team.teammembers
    @teammembers = teammembers.includes(:user).sort_by { |tm| tm.label.downcase }

    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # GET /teams/1/groups/1
  def show
    @group = team.groups.find(params[:id])
    authorize @group

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /teams/1/groups/new
  def new
    @group = team.groups.new
    authorize @group

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams/1/groups
  def create
    @group = team.groups.new(group_params)
    authorize @group

    respond_to do |format|
      if @group.save
        flash[:notice] = t('flashes.groups.created')
        format.html { redirect_to team_groups_url(team) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # GET /teams/1/groups/1/edit
  def edit
    @group = team.groups.find(params[:id])
    authorize @group

    groups_breadcrumbs

    respond_to do |format|
      format.html # edit.html.haml
    end
  end

  # PUT /teams/1/groups/1
  def update
    @group = team.groups.find(params[:id])
    authorize @group

    respond_to do |format|
      if @group.update_attributes(group_params)
        flash[:notice] = t('flashes.groups.updated')
        format.html { redirect_to team_groups_url(team) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1/groups/1
  def destroy
    @group = team.groups.find(params[:id])
    authorize @group
    @group.destroy

    respond_to do |format|
      format.html { redirect_to team_groups_url(team) }
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :description)
  end

  def groups_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path

    add_breadcrumb team.label if action_name == 'index'

    if action_name == 'edit'
      add_breadcrumb team.label, :team_groups_path
      add_breadcrumb @group.label
    end
  end

end
