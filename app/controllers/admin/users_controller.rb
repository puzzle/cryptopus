# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::UsersController < Admin::AdminController

  before_action :user, only: %i[edit update]

  helper_method :toggle_admin

  # GET /admin/users
  def index
    # defining @soloteams for further use in destroy action
    if flash[:user_to_delete].present?
      user_to_delete = User.find(flash[:user_to_delete])
      @soloteams = teams_to_delete(user_to_delete)
    end

    @users = User.where('uid != 0 or uid is null')

    respond_to do |format|
      format.html
    end
  end

  # PUT /admin/users/1
  def update
    user.update_attributes(user_update_params)

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  # DELETE /admin/users/1
  def destroy
    if user == current_user
      flash[:error] = t('flashes.admin.users.destroy.own_user')
    else
      destroy_user
    end

    respond_to do |format|
      format.html do
        redirect_to admin_users_path
      end
    end
  end

  # GET /admin/users/new
  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /admin/users
  def create
    password = params[:user][:password]

    @user = User.create_db_user(password, user_create_params)

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


  private

  def destroy_user
    # admins cannot be removed from non-private teams
    # so set admin to false first
    user.update!(admin: false) if user.admin?
    user.destroy!
  end

  def user
    @user ||= User.find(params[:id])
  end

  def user_create_params
    permit_user_params([:username, :givenname, :surname, :password])
  end

  def user_update_params
    if user.auth == 'db'
      permit_user_params([:username, :givenname, :surname])
    else
      permit_user_params(:username)
    end
  end

  def permit_user_params(attributes)
    params.require(:user).permit(attributes)
  end
end
