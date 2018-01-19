# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::RecryptrequestsController < Admin::AdminController

  # GET /admin/recryptrequests
  def index
    @recryptrequests = Recryptrequest.all
  end

  # DELETE /admin/recryptrequest/1
  def destroy
    @recryptrequest = Recryptrequest.find_by(id: params[:id])
    authorize @recryptrequest
    @user = @recryptrequest.user
    @admin = User.find(session[:user_id])

    recrypt_passwords(@recryptrequest.user, @admin, session[:private_key]) do
      @recryptrequest.destroy
      flash[:notice] = t('flashes.admin.recryptrequests.all', user_name: @user.username)
    end

    redirect_to admin_recryptrequests_path
  end

  # POST /admin/recryptrequests/resetpassword
  def resetpassword
    @user = User.find(params[:user_id])
    authorize @user
    @admin = User.find(session[:user_id])

    if @user.ldap? || blank_password?
      return redirect_back(fallback_location: admin_recryptrequests_path)
    end

    encrypt_and_save_user

    recrypt_passwords(@user, @admin, session[:private_key]) do
      flash[:notice] = t('flashes.admin.recryptrequests.resetpassword.success')
    end

    redirect_back(fallback_location: admin_recryptrequests_path)
  end

  private

  def encrypt_and_save_user
    @user.password = CryptUtils.one_way_crypt(params[:new_password])
    @user.create_keypair params[:new_password]
    @user.save
  end

  def recrypt_passwords(user, admin, private_key)
    user.last_teammember_teams.destroy_all
    user.teammembers.in_private_teams.destroy_all

    user.teammembers.in_non_private_teams.each do |tm|
      tm.recrypt_team_password(user, admin, private_key)
    end

    yield if block_given?
  rescue StandardError => e
    flash[:error] = e.message
  end

  def blank_password?
    if params[:new_password].blank?
      flash[:notice] = t('flashes.admin.recryptrequests.resetpassword.required')
      return true
    end
    false
  end
end
