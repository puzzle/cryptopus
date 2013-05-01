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

class Admin::UsersController < Admin::AdminController

private

  def empower_user(user)
    teams = Team.all
    for team in teams do

      # Decrypt the team password with the private key from the
      # logged in user. He has to be root or admin to get
      # admin rights to another user
      active_user = User.find( session[:user_id] )
 
      # skip teams we do not encrypt for admins
      next if team.private or team.noroot
  
      active_teammember = team.teammembers.find_by_user_id( active_user.id.to_s )
      team_password = CryptUtils.decrypt_team_password( active_teammember.password, session[:private_key] )

      # Create the new teammember per team and mark it as an
      # admin account
      teammember = team.teammembers.new
      teammember.password = CryptUtils.encrypt_team_password( team_password, user.public_key )
      teammember.admin = true
      teammember.user_id = user.id
      teammember.save
    end
  end

  def disempower_admin(user)
    teammembers = user.teammembers.find_all_by_admin( true )
    for teammember in teammembers do
      teammember.destroy
    end
  end

public

  # GET /admin/users
  def index
    @users = User.find( :all, :conditions => ["uid != 0 or uid is null"] )

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /admin/users/1/edit
  def edit
    @user = User.find( params[:id] )
  end

  # PUT /admin/users/1
  def update
    @user = User.find( params[:id] )
    was_admin = @user.admin
    @user.update_attributes( params[:user] )
    
    if @user.admin == true and not was_admin
      empower_user( @user )
    end

    if @user.admin == false and was_admin
      disempower_admin( @user )
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  # DELETE /admin/users/1
  def destroy
    @user = User.find( params[:id] )
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end
  
    # GET /admin/users/new
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /admin/users
  def create
    @user = User.new( params[:user] )
    
    @user.auth = 'db'
    @user.password = CryptUtils.one_way_crypt( @user.password )
    @user.create_keypair @user.password
    
    respond_to do |format|
      if @user.save
        flash[:notice] = "Successfully created a new user."
        format.html { redirect_to(admin_users_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
