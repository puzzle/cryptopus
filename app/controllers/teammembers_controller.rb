# $Id$
#
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

class TeammembersController < ApplicationController
  before_filter :load_team

private

  def load_team
    @team = Team.find( params[:team_id] )
  end

public

  # GET /teams/1/teammembers/new
  def new
    @users = User.find(:all, :conditions => ["uid != 0"])
    @users.reject! do |user| 
      Teammember.find(:first, :conditions => ["team_id = ? AND user_id = ? AND admin = false", @team.id, user.id])
    end  
    @user_list = @users.collect {|user| \
      [LdapTools.get_ldap_info( user.uid.to_s, "givenname" ) + " " + \
      LdapTools.get_ldap_info( user.uid.to_s, "sn" ), \
      LdapTools.get_ldap_info( user.uid.to_s, "uid" )]}
    @user_list.sort!
  end

  # POST /teams/1/teammembers
  def create
    begin
      user_uid = LdapTools.get_uid_by_username( params[:username] )
      user = User.find( :first, :conditions => ["uid = ?", user_uid] )
      raise "User is not in the database" if user.nil?
      raise "User is already in that Team" \
        if @team.teammembers.find( :first, :conditions => ["user_id = ?", user.id] )
      @teammember = Teammember.new
      @teammember.team_id = @team.id
      @teammember.user_id = user.id
      @teammember.password = CryptUtils.encrypt_team_password( get_team_password, user.public_key)
      @teammember.save
        
    rescue StandardError => e
      flash[:error] = e.message
    end

    respond_to do |format|  
      format.html { redirect_to team_groups_url(@team) }
    end
  end
  
  # DELETE /teams/1/teammembers/1
  def destroy
    @teammember = @team.teammembers.find( params[:id] )
    @teammember.destroy

    respond_to do |format|
      format.html { redirect_to team_groups_url(@team) }
    end
  end

end
