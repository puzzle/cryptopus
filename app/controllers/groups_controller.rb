# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class GroupsController < ApplicationController
  self.permitted_attrs = [:name, :description]

  helper_method :team

  # GET /teams/1/groups/1
  def show
    authorize group

    @accounts = group.accounts
    groups_breadcrumbs

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /teams/1/groups/new
  def new
    @group = team.groups.new
    authorize group

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams/1/groups
  def create
    @group = team.groups.new(model_params)
    authorize group

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
    authorize group

    groups_breadcrumbs

    respond_to do |format|
      format.html # edit.html.haml
    end
  end

  # PUT /teams/1/groups/1
  def update
    authorize group

    respond_to do |format|
      if group.update!(model_params)
        flash[:notice] = t('flashes.groups.updated')
        format.html { redirect_to team_groups_url(team) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1/groups/1
  def destroy
    authorize group

    group.destroy!

    respond_to do |format|
      format.html { redirect_to team_url(team) }
    end
  end

  private

  def groups_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path
    add_breadcrumb team.label, team_path(team.id)
    add_breadcrumb group.label
  end

  def group
    @group ||= team.groups.find(params[:id])
  end
end
