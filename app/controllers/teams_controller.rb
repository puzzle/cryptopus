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

  def index
    redirect_to :action => 'list'
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
     #@group_pages, @groups = paginate :groups, :per_page => 10
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
     end
  end

  def new
    if request.get?
      @team = Team.new    
    else
      @team = Team.new( params[:team] )
      @team.created_on = Time.now
      @team.updated_on = Time.now
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
        team_member_user.save
        
        flash[:notice] = 'Team was successfully created.'
        redirect_to :action => 'list'
      end
    end
  end

  def edit
    if request.get?
      @team = Team.find(:first, :conditions => ["id = ?", params[:id]] )
    else
      @team = Team.find(:first, :conditions => ["id = ?", params[:id]] )
      @team.updated_on = Time.now
      if @team.update_attributes( params[:team] )
        flash[:notice] = 'Team was successfully updated.'
        redirect_to :action => 'show', :id => @team
      else
        flash[:error] = "An error occured while updating"
      end
    end
  end

  def destroy
    if (Team.find(:first, :conditions => ["id = ?", params[:id]] ).destroy==1)
      flash[:notice] = "Team have been deleted..."
    else
      flash[:error] = "An error occured while trying to delete the entry"
    end
    redirect_to :action => 'list'
  end
  
end
