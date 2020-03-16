# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::UsersController < ApplicationController
  before_action :redirect_if_ldap_user, only: [:update, :edit]
  before_action :authorize_user_class, only: [:index, :new, :create]
  before_action :authorize_user, only: [:update, :unlock, :edit]

  helper_method :update_role

  # GET /admin/users
  def index
    authorize User::Human
    @users = User::Human.all.unlocked

    respond_to do |format|
      format.html
    end
  end

  # PUT /admin/users/1
  def update
    user.update!(permitted_attributes(user))

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  # GET /admin/users/new
  def new
    @user = User::Human.new
    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /admin/users
  def create
    @user = User::Human.create_db_user(password, permitted_attributes(User::Human))

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

  def redirect_if_ldap_user
    return unless user.ldap?

    flash[:error] = t('flashes.admin.users.update.ldap')

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def user
    @user ||= User::Human.find(params[:id])
  end

  def password
    params[:user_human][:password]
  end

  def authorize_user_class
    authorize User::Human
  end

  def authorize_user
    authorize user
  end
end
