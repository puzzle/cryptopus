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

  before_filter :validate_change_rights, :only => [:edit, :update]

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
    @team = Team.find( params[:id] )
  end

  # PUT /teams/1
  def update
    @team = Team.find( params[:id] )
    @team.updated_on = Time.now

    respond_to do |format|
      if @team.update_attributes( team_params )

        @team_password = get_team_password(@team)

        if @team.private == true
          remove_admins_from_team
        else
          add_admins_to_team
        end

        if @team.noroot == true
          remove_root_from_team
        else
          add_root_to_team
        end

        flash[:notice] = t('flashes.teams.updated')
        format.html { redirect_to(teams_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /teams/1
  def destroy
    @team = Team.find( params[:id] )
    if (current_user.admin? || current_user.root? || @team.last_teammember?(current_user.id))
       @team.destroy
       flash[:notice] = t('flashes.teams.deleted')
    else
      flash[:error] = t('flashes.teams.cannot_delete')
    end

    redirect_to(teams_path)
  end

  private
    def team_params
      params.require(:team).permit(:name, :private, :noroot, :description)
    end

    def validate_change_rights
      unless am_i_team_member( params[:id] )
        redirect_to :controller => 'login', :action => 'noaccess', :message => "You are not member of this team"
        return
      end
    end

    def add_user_to_team( user, admin )
      team_member = user.teammembers.new
      team_member.team_id = @team.id
      team_member.password = CryptUtils.encrypt_team_password( @team_password, user.public_key )
      if admin == true
        team_member.admin = true
      end
      team_member.save
    end

    def add_root_to_team
      root = User.find_by_uid( "0" )

      # Check if the root is already in the Team
      teammember_root = @team.teammembers.find_by_user_id( root.id )
      return unless teammember_root.nil?

      add_user_to_team( root, true )
    end

    def add_admins_to_team
      admins = User.where(admin:  true ).load
      for admin in admins do
        # Exclude root
        next if admin.uid == 0

        # Check it the Admin is already in the Team
        already_in_team = false
        teammembers_admin = @team.teammembers.where(user_id: admin.id ).load
        for teammember_admin in teammembers_admin do
          already_in_team = true if teammember_admin.admin == true
        end
        next if already_in_team == true

        add_user_to_team( admin, true )
      end
    end

    def remove_root_from_team
      root = User.find_by_uid( "0" )
      teammember_root = @team.teammembers.find_by_user_id( root.id )
      teammember_root.destroy unless teammember_root.nil?
    end

    def remove_admins_from_team
      admins = @team.teammembers.where(admin: true)
      for admin in admins do
        admin.destroy unless admin.user.root?
      end
    end
end
