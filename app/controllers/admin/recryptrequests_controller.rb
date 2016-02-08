# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::RecryptrequestsController < Admin::AdminController

  private

    def recrypt_passwords(user, admin, is_not_root)
          # Recrypt all the passwords
      user.teammembers.each do |teammember_user|
        # Skip private passwords if an admin is recrypting
        next if teammember_user.team.private and is_not_root
        # Skip noroot passwords
        next if teammember_user.team.noroot

        teammember_admin = admin.teammembers.find_by_team_id( teammember_user.team_id )
        team_password = CryptUtils.decrypt_team_password( teammember_admin.password, session[:private_key] )
        teammember_user.password = CryptUtils.encrypt_team_password( team_password, @user.public_key )
        teammember_user.locked = false
        teammember_user.save
      end
    end

  public

  # GET /admin/recryptrequests
  def index
    @recryptrequests = Recryptrequest.all
  end

  # DELETE /admin/recryptrequest/1
  def destroy
    @recryptrequest = Recryptrequest.find_by(id: params[:id] )
    @user = @recryptrequest.user
    @admin = User.find( session[:user_id] )

    # Check if the user that tries to recrypt the passwords is root
    # or just an admin.
    is_not_root = !@admin.root?

    begin

      recrypt_passwords( @recryptrequest.user, @admin, is_not_root )

      if is_not_root
        @recryptrequest.adminrequired = false
        @recryptrequest.save
        flash[:notice] = t('flashes.admin.recryptrequests.some', :user_name => @user.username)
      else
        @recryptrequest.adminrequired = false
        @recryptrequest.rootrequired = false
      end

      unless @recryptrequest.adminrequired and @recryptrequest.rootrequired
        @recryptrequest.destroy
        flash[:notice] = t('flashes.admin.recryptrequests.all', :user_name => @user.username)
      end

    rescue StandardError => e
      flash[:error] = e.message

    end

    redirect_to admin_recryptrequests_path

  end

  # POST /admin/recryptrequests/resetpassword
  def resetpassword
    @user = User.find( params[:user_id] )
    @admin = User.find( session[:user_id] )

    if @user.auth_db?
      unless params[:new_password].blank?
        @user.password = CryptUtils.one_way_crypt( params[:new_password] )

        # create the new keypair
        keypair = CryptUtils.new_keypair
        @user.public_key = CryptUtils.get_public_key_from_keypair( keypair )
        private_key = CryptUtils.get_private_key_from_keypair( keypair )
        @user.private_key = CryptUtils.encrypt_private_key( private_key, params[:new_password] )
        @user.save

        # lock all team memberships
        @user.teammembers.each do |teammember|
          teammember.locked = true
        end

        is_not_root = !@admin.root?

        recrypt_passwords( @user, @admin, is_not_root )

        flash[:notice] = t('flashes.admin.recryptrequests.resetpassword.success')
      else
        flash[:notice] = t('flashes.admin.recryptrequests.resetpassword.required')
      end
    end

    redirect_to :back
  end

end
