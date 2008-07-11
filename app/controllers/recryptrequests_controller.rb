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

  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if session[:uid] != "0"
      flash[:error] = "You failed to hack Cryptopus dude!"
      redirect_to :controller => 'groups', :action => 'list'
      return
    end
    @recryptrequests = Recryptrequest.find(:all)
  end
  
  def uncrypterror
  end

  def registerrequest
    if not LdapTools.ldap_login(LdapTools.get_ldap_info( session[:uid], "uid"), params[:newpassword] )
      flash[:error] = "Your password was wrong"
      redirect_to :action => 'uncrypterror'
      return
    end
  
    user = User.find( :first, :conditions => ["uid = ?" , session[:uid]] )
    if Recryptrequest.find( :first, :conditions => ["user_id = ?" , user.id] ).nil?
      keypair = CryptUtils.new_keypair
      user.public_key = CryptUtils.get_public_key_from_keypair( keypair )
      user.private_key = CryptUtils.encrypt_private_key( CryptUtils.get_private_key_from_keypair( keypair ), params[:newpassword] )
      user.save
      @recryptrequest = Recryptrequest.new
      @recryptrequest.user_id = user.id
      @recryptrequest.save
    end
    
    flash[:notice] = "Wait until the root has recrypted your group passwords"
    redirect_to :controller => 'login', :action => 'logout'
  end
  
  def selfrecrypt
    if not LdapTools.ldap_login( LdapTools.get_ldap_info( session[:uid], "uid" ), params[:newpassword] )
      flash[:error] = "Your password was wrong"
      redirect_to :action => 'uncrypterror'
      return
    end
  
    begin
      user = User.find( :first, :conditions => ["uid = ?" , session[:uid]] )
      user.private_key = CryptUtils.encrypt_private_key( CryptUtils.decrypt_private_key( user.private_key, params[:oldpassword] ), params[:newpassword] )
      user.save
      flash[:notice] = "You have successfully recrypted the password"
    
    rescue StandardError => message
      flash[:error] = message
      
    end
    redirect_to :controller => 'login', :action => 'logout'
  end

  def recrypt
    if session[:uid] != "0"
      flash[:error] = "You failed to hack Cryptopus dude!"
      redirect_to :controller => 'groups', :action => 'list'
      return
    end
    
    begin
      @user = User.find(:first, :conditions => ["group_id = ?", params[:user_id]] )
      @team_members = Teammember.find( :all, :conditions => ["user_id = ?" , params[:user_id]] )
      for team_member_user in @team_members
        team_member_root = Teammember.find( :first, :conditions => ["user_uid = ? and group_id = ?" , session[:uid], team_member_user.team_id] )
        team_password = CryptUtils.decrypt_team_password( team_member_root.password, session[:private_key] )
        team_member_user.password = CryptUtils.encrypt_team_password( team_password, @user.public_key )
        team_member_user.save
      end
      @recryptrequest = Recryptrequest.find( :first, :conditions => ["user_id = ?" , params[:user_id]] )
      @recryptrequest.destroy
      
    rescue StandardError => message
      flash[:error] = message
      
    else
      flash[:notice] = "successfully recrypted the password for " + LdapTools.get_ldap_info( @user.uid, "cn" )

    end
    redirect_to :action => 'list'
  end

end
