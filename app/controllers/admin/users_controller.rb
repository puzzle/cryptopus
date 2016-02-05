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

  before_filter :redirect_if_root, only: [:edit, :update, :destroy]
  before_filter :redirect_if_ldap_user, only: [:edit, :update]

  # GET /admin/users
  def index
    @users = User.where("uid != 0 or uid is null")

    respond_to do |format|
      format.html
    end
  end

  # PUT /admin/users/1
  def update
    was_admin = user.admin?
    user.update_attributes( user_params )
    update_attribute_admin(was_admin)

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  # DELETE /admin/users/1
  def destroy
    if user == current_user
      flash[:error] = t('flashes.admin.users.destroy.own_user')
    else
      user.destroy
    end

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
    password = params[:user][:password]

    @user = User.create_db_user(password, user_params)

    respond_to do |format|
      if @user.save
        flash[:notice] = t('flashes.admin.users.created')
        format.html { redirect_to admin_users_url }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def unlock
    user.unlock

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def user_params
    params.require(:user).permit(:name, :username, :password, :admin, :givenname, :surname, :auth)
  end

private
  def redirect_if_ldap_user
    return if not user.auth == 'ldap'

    flash[:error] = t('flashes.admin.users.update.ldap')

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end
  def redirect_if_root
    return if not user.root?

    if params[:action] == 'destroy'
      flash[:error] = t('flashes.admin.users.destroy.root')
    else
      flash[:error] = t('flashes.admin.users.update.root')
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def user
    @user ||= User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :givenname, :surname, :admin, :password, :auth)
  end

  def empower_user(user)
    teams = Team.where("private = ? OR noroot = ?", false, false)

    teams.each do |t|
      active_teammember = t.teammembers.find_by_user_id( current_user.id.to_s )
      team_password = CryptUtils.decrypt_team_password( active_teammember.password, session[:private_key] )
      t.add_user(user, team_password)
    end
  end

  def disempower_admin(user)
    teammembers = user.teammembers.joins(:team).where(teams:{private: false})
    teammembers.each do |tm|
      tm.destroy
    end
  end

  def update_attribute_admin(was_admin)
    if @user.admin? and !was_admin
      empower_user( @user )
    end

    if !@user.admin? and was_admin
      disempower_admin( @user )
    end
  end
end
