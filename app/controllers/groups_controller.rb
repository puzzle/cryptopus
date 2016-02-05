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

class GroupsController < ApplicationController
  before_filter :load_team

  # GET /teams/1/groups
  def index
    groups_breadcrumbs


    @groups = @team.groups

    teammembers = @team.teammembers.without_root
    @teammembers = teammembers.sort_by { |tm| tm.label.downcase}

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /teams/1/groups/1
  def show
    @group = @team.groups.find( params[:id] )

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /teams/1/groups/new
  def new
    @group = @team.groups.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /teams/1/groups
  def create
    @group = @team.groups.new( group_params )

    respond_to do |format|
      if @group.save
        flash[:notice] = t('flashes.groups.created')
        format.html { redirect_to team_groups_url(@team) }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # GET /teams/1/groups/1/edit
  def edit
    @group = @team.groups.find( params[:id] )

    groups_breadcrumbs


    respond_to do |format|
      format.html # edit.html.erb
    end
  end

  # PUT /teams/1/groups/1
  def update
    @group = @team.groups.find( params[:id] )

    respond_to do |format|
      if @group.update_attributes( params[:group] )
        flash[:notice] = t('flashes.groups.updated')
        format.html { redirect_to team_groups_url(@team) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /teams/1/groups/1
  def destroy
    @group = @team.groups.find( params[:id] )
    @group.destroy

    respond_to do |format|
      format.html { redirect_to team_groups_url(@team) }
    end
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end

private

  def group_params
    params.require(:group).permit(:name, :description)
  end

  def load_team
    @team = Team.find( params[:team_id] )
  end

  def groups_breadcrumbs
    add_breadcrumb I18n.t('teams.title'), :teams_path

    add_breadcrumb @team.label if action_name == 'index'

    if action_name == 'edit'
      add_breadcrumb @team.label, :team_groups_path
      add_breadcrumb @group.label
    end
  end

end
