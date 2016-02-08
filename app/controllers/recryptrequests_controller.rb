# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class RecryptrequestsController < ApplicationController
  include User::Authenticate

  private

  def self_recrypt(old_password, new_password)
    @user = User.find_by(username: session[:username])
    # Check if the new password is ok
    @user.authenticate(new_password)

    # decrypt the private key with the old password
    # and encrypt it with the new one
    private_key = CryptUtils.decrypt_private_key(@user.private_key, old_password)
    CryptUtils.validate_keypair(private_key, @user.public_key)
    @user.private_key = CryptUtils.encrypt_private_key(private_key, new_password)
    @user.save

    flash[:notice] = t('flashes.recryptrequests.recrypted')
    redirect_to logout_login_path
    return

  rescue Exceptions::AuthenticationFailed
    flash[:error] = t('flashes.recryptrequests.new_password_wrong')
    redirect_to new_recryptrequest_path
    return

  rescue Exceptions::DecryptFailed
    flash[:error] = t('flashes.recryptrequests.old_password_wrong')
    redirect_to new_recryptrequest_path
    return
  end

  public

  # GET /recryptrequests/
  def index
    @user = User.find(session[:user_id])
    @recryptrequest = Recryptrequest.find_by_user_id(@user.id)

    if @recryptrequest.nil?
      redirect_to new_recryptrequest_path
      return
    end

    redirect_to recryptrequest_path(@recryptrequest)
  end

  # GET /recryptrequests/new
  def new
    @user = User.find(session[:user_id])
  end

  # POST /recryptrequests
  def create
    # If the user knows his old password we can
    # still decrypt the private key
    if params[:recrypt_request].nil?
      self_recrypt params[:old_password], params[:new_password]
      return
    end

    # If not we have to create a new keypair and send
    # a request to root to decrypt the teampasswords
    # for us
    begin
      @user = User.find_by_username(session[:username])

      @user.authenticate(params[:new_password])

      # Check if that was already done
      if @user.recryptrequests.load.empty?

        # create the new keypair
        keypair = CryptUtils.new_keypair
        @user.public_key = CryptUtils.get_public_key_from_keypair(keypair)
        private_key = CryptUtils.get_private_key_from_keypair(keypair)
        @user.private_key = CryptUtils.encrypt_private_key(private_key, params[:new_password])
        @user.save

        # send the recryptrequest to root
        @recryptrequest = @user.recryptrequests.new
        @recryptrequest.rootrequired = false
        @recryptrequest.adminrequired = true
      end

      # lock all teams for this user and check
      # if an admin could do the job or if root
      # is required
      @user.teammembers.each do |teammember|
        teammember.locked = true
        teammember.save
        if teammember.team.private
          @recryptrequest.rootrequired = true
        end
      end

      @recryptrequest.save
      flash[:notice] = t('flashes.recryptrequests.wait')
      redirect_to logout_login_path
      return

    rescue Exceptions::AuthenticationFailed
      flash[:error] = t('flashes.recryptrequests.wrong_password')
      redirect_to new_recryptrequest_path
      return

    end
  end

  # GET /recryptrequests/1
  def show
    @user = User.find(session[:user_id])
    @recryptrequest = Recryptrequest.find_by_user_id(@user.id)
  end

end
