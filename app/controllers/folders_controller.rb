# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class FoldersController < ApplicationController
  self.permitted_attrs = [:name, :description]

  helper_method :team

  # GET /teams/1/folders/1
  def show
    authorize folder

    @accounts = folder.accounts
    folders_breadcrumbs

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # GET /teams/1/folders/new
  def new
    @folder = team.folders.new
    authorize folder

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams/1/folders
  def create
    @folder = team.folders.new(model_params)
    authorize folder

    respond_to do |format|
      if @folder.save
        flash[:notice] = t('flashes.folders.created')
        format.html { redirect_to team_folders_url(team) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # GET /teams/1/folders/1/edit
  def edit
    authorize folder

    folders_breadcrumbs

    respond_to do |format|
      format.html # edit.html.haml
    end
  end

  # PUT /teams/1/folders/1
  def update
    authorize folder

    respond_to do |format|
      if folder.update!(model_params)
        flash[:notice] = t('flashes.folders.updated')
        format.html { redirect_to team_folders_url(team) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1/folders/1
  def destroy
    authorize folder

    folder.destroy!

    respond_to do |format|
      format.html { redirect_to team_url(team) }
    end
  end

  private

  def folders_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path
    add_breadcrumb team.label, team_path(team.id)
    add_breadcrumb folder.label
  end

  def folder
    @folder ||= team.folders.find(params[:id])
  end
end
