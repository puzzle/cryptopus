# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
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
    @user = @recryptrequest.user
    @admin = User.find(session[:user_id])

    recrypt_passwords(@recryptrequest.user, @admin) do
      @recryptrequest.destroy
      flash[:notice] = t('flashes.admin.recryptrequests.all', user_name: @user.username)
    end

    redirect_to admin_recryptrequests_path
  end

  # POST /admin/recryptrequests/resetpassword
  def resetpassword
    @user = User.find(params[:user_id])
    @admin = User.find(session[:user_id])

    return redirect_to :back if @user.auth_ldap? || blank_password?

    @user.password = CryptUtils.one_way_crypt(params[:new_password])
    create_keypair

    recrypt_passwords(@user, @admin) do
      flash[:notice] = t('flashes.admin.recryptrequests.resetpassword.success')
    end

    redirect_to :back
  end

  private

  def recrypt_passwords(user, admin)
    user.teammembers.non_private_teams.each do |tm|
      user.last_teammember_teams.each do |td|
        td.destroy
      end
      recrypt_team_password(tm, admin)
    end
    yield if block_given?
  rescue StandardError => e
    flash[:error] = e.message
  end

  def recrypt_team_password(tm, admin)
    teammember_admin = admin.teammembers.find_by_team_id(tm.team_id)
    team_password = CryptUtils.decrypt_team_password(teammember_admin.
      password, session[:private_key])

    tm.password = CryptUtils.encrypt_team_password(team_password, @user.public_key)
    tm.save
  end

  def create_keypair
    keypair = CryptUtils.new_keypair
    @user.public_key = CryptUtils.get_public_key_from_keypair(keypair)
    private_key = CryptUtils.get_private_key_from_keypair(keypair)
    @user.private_key = CryptUtils.encrypt_private_key(private_key, params[:new_password])
    @user.save
  end

  def blank_password?
    if params[:new_password].blank?
      flash[:notice] = t('flashes.admin.recryptrequests.resetpassword.required')
      return true
    end
    false
  end
end
