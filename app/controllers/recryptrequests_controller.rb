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

class RecryptrequestsController < ApplicationController

private

  def self_recrypt( old_password, new_password )
    if not LdapTools.ldap_login( LdapTools.get_ldap_info( session[:uid], "uid" ), new_password )
      flash[:error] = "Your password was wrong"
      redirect_to new_recryptrequest_path
      return
    end
  
    @user = User.find( :first, :conditions => ["uid = ?" , session[:uid]] )
    begin
      private_key = CryptUtils.decrypt_private_key( @user.private_key, old_password )
    rescue
      private_key = CryptUtilsLegacy.decrypt_private_key( @user.private_key, old_password )
    end
    @user.private_key = CryptUtils.encrypt_private_key( private_key, new_password )
    @user.save
    
    flash[:notice] = "You have successfully recrypted the password"
    redirect_to :controller => 'login', :action => 'logout'
  end

public

  # GET /recryptrequests/
  def index
    @user = User.find_by_uid( session[:uid] )
    @recryptrequest = Recryptrequest.find_by_user_id(@user.id)

    if @recryptrequest.nil?
      redirect_to new_recryptrequest_path
      return
    end

    redirect_to recryptrequest_path(@recryptrequest)
  end

  # GET /recryptrequests/new
  def new
    @user = User.find_by_uid( session[:uid] )
  end

  # POST /recryptrequests
  def create
    if params[:recrypt_request].nil? 
      self_recrypt params[:old_password], params[:new_password]
      return
    end

    if not LdapTools.ldap_login(LdapTools.get_ldap_info( session[:uid], "uid"), params[:new_password] )
      flash[:error] = "Your password was wrong"
      redirect_to new_recryptrequest_path
      return
    end
  
    @user = User.find_by_uid( session[:uid] )

    if @user.recryptrequests.find(:all).empty?
      keypair = CryptUtils.new_keypair
      @user.public_key = CryptUtils.get_public_key_from_keypair( keypair )
      private_key = CryptUtils.get_private_key_from_keypair( keypair )
      @user.private_key = CryptUtils.encrypt_private_key( private_key, params[:new_password] )
      @user.save
      @recryptrequest = @user.recryptrequests.new
      @recryptrequest.rootrequired = false
      @recryptrequest.adminrequired = true
    end
    
    @user.teammembers.each do |teammember|
      teammember.locked = true
      teammember.save

      if teammember.team.private
	@recryptrequest.rootrequired = true
      end
    end
	
    @recryptrequest.save
    flash[:notice] = "Wait until root has recrypted your team passwords"
    redirect_to :controller => 'login', :action => 'logout'
   
  end

  # GET /recryptrequests/1
  def show
    @user = User.find_by_uid( session[:uid] )
    @recryptrequest = Recryptrequest.find_by_user_id(@user.id)
  end

end
