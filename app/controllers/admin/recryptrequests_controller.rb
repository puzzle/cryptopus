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

  # GET /admin/recryptrequests
  def index
    @recryptrequests = Recryptrequest.find(:all)
  end

  # DELETE /admin/recryptrequest/1
  def destroy
    @recryptrequest = Recryptrequest.find( params[:id] )
    @user = @recryptrequest.user
    @admin = User.find_by_uid( session[:uid] )
    
    # Check if the user that tries to recrypt the passwords is root
    # or just an admin.
    is_not_root = true
    is_not_root = false if session[:uid] == '0'
    
    begin

      # Recrypt all the passwords
      @recryptrequest.user.teammembers.each do |teammember_user|
        # Skip private passwords if an admin is recrypting
        next if teammember_user.team.private and is_not_root
        # Skip noroot passwords
        next if teammember_user.team.noroot

        teammember_admin = @admin.teammembers.find_by_team_id( teammember_user.team_id )
        team_password = CryptUtils.decrypt_team_password( teammember_admin.password, session[:private_key] )
        teammember_user.password = CryptUtils.encrypt_team_password( team_password, @user.public_key )
        teammember_user.locked = false
        teammember_user.save
      end

      username = LdapTools.get_ldap_info( @user.uid, "cn" )
      
      if is_not_root
        @recryptrequest.adminrequired = false
        @recryptrequest.save
        flash[:notice] = "successfully recrypted some passwords for " + username
      end
      
      unless @recryptrequest.adminrequired and @recryptrequest.rootrequired
        @recryptrequest.destroy
        flash[:notice] = "successfully recrypted all password for " + username
      end
      
    rescue StandardError => e
      flash[:error] = e.message

    end

    redirect_to recryptrequests_path

  end

end
