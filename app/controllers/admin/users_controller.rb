# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::UsersController < ApplicationController

  before_action :redirect_if_ldap_user, only: %i[edit update]
  before_action :authorize_user_class, only: %i[index new create]
  before_action :authorize_user, only: %i[update unlock]

  helper_method :update_role

  # GET /admin/users
  def index
    # defining @soloteams for further use in destroy action
    if flash[:user_to_delete].present?
      user_to_delete = User.find(flash[:user_to_delete])
      @soloteams = teams_to_delete(user_to_delete)
    end

    @users = policy_scope(User)

    respond_to do |format|
      format.html
    end
  end

  # PUT /admin/users/1
  def update
    user.update_attributes(user_params)

    respond_to do |format|
      format.html { redirect_to admin_users_path }
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


  private

  def destroy_user
    # admins cannot be removed from non-private teams
    # so set admin to false first
    user.update!(role: User::Role::USER) if user.admin?
    user.destroy!
  end

  def redirect_if_ldap_user
    return unless user.ldap?

    flash[:error] = t('flashes.admin.users.update.ldap')

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def user
    @user ||= User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :givenname, :surname, :password)
  end

  def password
    params[:user][:password]
  end

  def authorize_user_class
    authorize User
  end

  def authorize_user
    authorize user
  end
end
