# $Id$

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
    @recryptrequest = Recryptrequest.find( params[:id] )
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
