# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::UsersController < Admin::AdminController

  before_filter :redirect_if_root, only: [:edit, :update, :destroy]
  before_filter :redirect_if_ldap_user, only: [:edit, :update]

  # GET /admin/users
  def index
    @users = User.where('uid != 0 or uid is null')

    respond_to do |format|
      format.html
    end
  end

  # PUT /admin/users/1
  def update
    was_admin = user.admin?
    user.update_attributes(user_params)
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
    return unless user.auth == 'ldap'

    flash[:error] = t('flashes.admin.users.update.ldap')

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def redirect_if_root
    return unless user.root?

    flash[:error] = if params[:action] == 'destroy'
                      t('flashes.admin.users.destroy.root')
                    else
                      t('flashes.admin.users.update.root')
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
    teams = Team.where('private = ? OR noroot = ?', false, false)

    teams.each do |t|
      active_teammember = t.teammembers.find_by_user_id(current_user.id.to_s)
      team_password = CryptUtils.decrypt_team_password(active_teammember.password, session[:private_key])
      t.add_user(user, team_password)
    end
  end

  def disempower_admin(user)
    teammembers = user.teammembers.joins(:team).where(teams: { private: false })
    teammembers.each do |tm|
      tm.destroy
    end
  end

  def update_attribute_admin(was_admin)
    if @user.admin? && !was_admin
      empower_user(@user)
    end

    if !@user.admin? && was_admin
      disempower_admin(@user)
    end
  end
end
