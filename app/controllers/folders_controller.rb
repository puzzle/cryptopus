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
