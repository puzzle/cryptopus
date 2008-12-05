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
  
  before_filter :validate_change_rights, :only => [:edit, :update, :destroy]
  
private

  def validate_change_rights
    unless am_i_team_member( params[:id] )
      redirect_to :controller => 'login', :action => 'noaccess', :message => "You are not member of this team"
      return
    end
    unless am_i_team_admin( params[:id] )
      redirect_to :controller => 'login', :action => 'noaccess', :message => "You are not administrator of this team"
      return
    end
  end
  
public

  # GET /teams
  def index
    if session[:uid].nil?
      flash[:error] = 'Enter a correct username and password or check the LDAP Settings'
      redirect_to :controller => 'login', :action => 'login'
      return
    else

      user = User.find( :first, :conditions => ["uid = ?" , session[:uid]] )
      team_members = Teammember.find( :all, :conditions => ["user_id=?", user.id] )
      @team_list = Hash.new
      team_members.each do |team_member|
        @team_list[team_member.team_id] = Hash.new
        @team_list[team_member.team_id][:team] = Team.find(:first, :conditions => ["id = ?", team_member.team_id ] )
        @team_list[team_member.team_id][:admin] = team_member.team_admin
      end

      respond_to do |format|
        format.html # index.html.erb
      end
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
    @team = Team.new( params[:team] )
    @team.created_on = Time.now
    @team.updated_on = Time.now

    respond_to do |format|
      if @team.save
        team_password = CryptUtils.new_team_password
      
        root = User.find( :first, :conditions => ["uid = ?" , "0"] )
        team_member_root = Teammember.new
        team_member_root.team_id = @team.id
        team_member_root.user_id = root.id
        team_member_root.password = CryptUtils.encrypt_team_password( team_password, root.public_key )
        team_member_root.team_admin = true
        team_member_root.save
      
        user = User.find( :first, :conditions => ["uid = ?" , session[:uid]] )
        team_member_user = Teammember.new
        team_member_user.team_id = @team.id
        team_member_user.user_id = user.id
        team_member_user.password = CryptUtils.encrypt_team_password( team_password, user.public_key )
        team_member_user.team_admin = true
        team_member_user.save
      
        flash[:notice] = 'Successfully created a new team.'
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
      if @team.update_attributes( params[:team] )
        flash[:notice] = 'Team was successfully updated.'
        format.html { redirect_to(teams_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /teams/1
  def destroy
    @team = Team.find( params[:id] )
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(teams_url) }
    end
  end
  
end
