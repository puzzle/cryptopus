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
    authorize team

    @folders = team.folders
    folders_breadcrumbs

    respond_to do |format|
      format.html # index.html.haml
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

  def folders_breadcrumbs
    add_breadcrumb t('teams.title'), :teams_path

    add_breadcrumb team.label if action_name == 'show'

    if action_name == 'edit'
      add_breadcrumb team.label, :team_folder_path
      add_breadcrumb @folder.label
    end
  end

  def team
    @team ||= Team.find(params[:id])
  end
end
