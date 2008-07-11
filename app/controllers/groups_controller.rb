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
       unless params[:team_id].nil?
         session[:active_team_id] = params[:team_id]
       end
       if session[:active_team_id].nil?
         redirect_to :controller => 'teams', :action => 'list'
         return
       end
       root = User.find( :first, :conditions => ["uid = ?" , "0"] )
       @groups = Group.find( :all, :conditions => [ "team_id=?", session[:active_team_id] ] )
       @team_members = Teammember.find( :all, :conditions => ["team_id = ? and not user_id = ?" , session[:active_team_id], root.id] )
       @team_name = Team.find(:first, :conditions => ["id = ?", session[:active_team_id]]).name
     end
  end

  def show
    @group = Group.find(:first, :conditions => ["group_id = ?", params[:id]] )
  end

  def new
    if request.get?
      @group = Group.new
    else
      @group = Group.new( params[:group] )
      @group.created_on = Time.now
      @group.updated_on = Time.now
      @group.team_id = session[:active_team_id]
      unless @group.save
        render :action => 'new'
      end
      flash[:notice] = 'Group was successfully created.'
      redirect_to :action => 'list'
    end
  end

  def edit
    if request.get?
      @group = Group.find(:first, :conditions => ["id = ?", params[:id]] )
    else
      @group = Group.find(:first, :conditions => ["group_id = ?", params[:id] ] )
      @group.updated_on = Time.now
      if @group.update_attributes( params[:group] )
        flash[:notice] = 'Group was successfully updated.'
        redirect_to :action => 'show', :id => @group
      else
        render :action => 'edit'
      end
   end
  end

  def destroy
    Group.find(:first, :conditions => ["group_id = ?", params[:id]] ).destroy
    redirect_to :action => 'list'
  end
  
  def add_user
    if request.get?
      @users = User.find(:all, :conditions => ["uid != 0"])
      @user_list = @users.collect {|user| [LdapTools.get_ldap_info( user.uid.to_s, "cn" ), LdapTools.get_ldap_info( user.uid.to_s, "uid" )]}
    else
      begin
        user_uid = LdapTools.get_uid_by_username( params[:username] )
        user = User.find( :first, :conditions => ["uid = ?", user_uid] )
        raise "User is not in the database" if user.nil?
        raise "User is already in that Team" \
          if Teammember.find( :first, :conditions => ["user_id = ? and team_id = ?", user.id, session[:active_team_id]] )
        team_member = Teammember.new
        team_member.team_id = session[:active_team_id]
        team_member.user_id = user.id
        team_member.password = CryptUtils.encrypt_team_password( get_team_password, user.public_key)
        team_member.save
        
      rescue StandardError => message
        flash[:error] = message
      end
      redirect_to :action => 'list'
    end
  end
  
  def del_user
    begin
      Teammember.find( :first, :conditions => ["user_id = ? and team_id = ?", params[:user_id], session[:active_team_id]] ).destroy
      
    rescue StandardError => message
      flash[:error] = message
    end
    redirect_to :action => 'list'
  end
  
end
