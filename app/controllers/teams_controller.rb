# $Id$

# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'crypt_utils'

class TeamsController < ApplicationController
  before_filter :redirect_if_not_teammember_or_admin, except: [:index, :new, :create]
  before_filter :redirect_if_not_allowed_to_delete_team, only: [:destroy]
  helper_method :can_delete_team?

  # GET /teams
  def index
    @teams = current_user.teams

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /teams/new
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /teams
  def create
    respond_to do |format|
      if Team.create(current_user, team_params)
        flash[:notice] = t('flashes.teams.created')
        format.html { redirect_to(teams_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # GET /teams/1/edit
  def edit
  end

  # PUT /teams/1
  def update
    respond_to do |format|
      if @team.update_attributes( team_params )

        flash[:notice] = t('flashes.teams.updated')
        format.html { redirect_to(teams_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /teams/1
  def destroy
    @team.destroy
    flash[:notice] = t('flashes.teams.deleted')
    redirect_to teams_path
  end

  # GET /teams/1/teammember_candidates
  def teammember_candidates
    render :json, @team.teammember_candidates
  end

  private
    def team_params
      params.require(:team).permit(:name, :private, :noroot, :description)
    end

    def redirect_if_not_teammember_or_admin
      @team = Team.find( params[:id] )
      unless @team.teammember?( current_user.id ) || current_user.admin? || current_user.root?
        flash[:error] = "You are not member of this team"
        redirect_to teams_path
        return
      end
    end

    def redirect_if_not_allowed_to_delete_team
      unless can_delete_team?(@team)
        flash[:error] = t('flashes.teams.cannot_delete')
        redirect_to teams_path
        return
      end
    end

    def can_delete_team?(team)
      current_user.admin? || current_user.root?
    end
end
