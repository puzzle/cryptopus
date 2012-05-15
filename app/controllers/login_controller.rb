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

require 'net/ldap'
require 'crypt_utils'
require 'crypt_utils_legacy'
require 'ldap_tools'

class LoginController < ApplicationController

private

  def create_session(user, password)
    session[:username] = user.username
    # @@@TODO remove this if replaced in other methods
    session[:uid] = user.uid
    begin
      session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, password )
    rescue
      begin
        # This tries to decrypt with legacy crypt methods and migrates to the current method
        session[:private_key] = CryptUtilsLegacy.decrypt_private_key( user.private_key, password )
        user.private_key = CryptUtils.encrypt_private_key( session[:private_key], password )
        user.save
      rescue
        raise Exceptions::DecryptFailed
      end
    end
    # validate private key
    test_data = 'Test Data'
    encrypted_test_data = CryptUtils.encrypt_team_password( test_data, user.public_key )
    raise Exceptions::DecryptFailed unless test_data == CryptUtils.decrypt_team_password( encrypted_test_data, session[:private_key] )
  end

public

  def login
    unless User.find_by_uid(0)
      flash[:notice] = 'Welcome to Cryptopus, First you have to create a new Root account. Please enter "root" as username and enter a new password'
    end
    if session[:username]
      redirect_to teams_path
    end
  end 
    
  def authenticate
    begin
      begin
        User.authenticate params[:username], params[:password]
      rescue Exceptions::UserDoesNotExist
        if params[:username] == 'root'
          User.create_root params[:password]
        else
          User.create_from_external_auth params[:username], params[:password]
        end  
      end
    rescue Exceptions::UserCreationFailed, Exceptions::AuthenticationFailed
      flash[:error] = 'Authentication failed! Enter a correct username and password.'
      render :action => 'login'
      return
    end
    
    begin
      @user = User.find_by_username params[:username]
      @user.update_info
      create_session(@user, params[:password])
    rescue Exceptions::DecryptFailed
      redirect_to recryptrequests_path
      return
    end
    
    if session[:jumpto].nil? or session[:jumpto].empty?
      redirect_to teams_path
    else
      jump_to = session[:jumpto]
      session[:jumpto] = nil
      redirect_to jump_to
    end
    return
  end
  
  def logout
    # This is ugly, i'm sure there is a better way
    jump_to = session[:jumpto]
    keep_notice = flash[:notice]
    keep_error  = flash[:error]
    reset_session
    flash[:notice] = keep_notice
    flash[:error]  = keep_error
    if jump_to
      redirect_to jump_to
      return
    end
  end
  
  def noaccess
    @message = "sorry"
    if params[:message]
      @message = params[:message]
    end
  end
  
  def pwdchange
    if request.get?
      if session[:uid] != "0"
        flash[:error] = "You are not root!"
        redirect_to teams_path
      end
    else
      if session[:uid] == "0"
        root = User.find( :first, :conditions => ["uid = ?", "0"] )
        crypted_password = CryptUtils.one_way_crypt( params[:oldpassword] )
        if root.password == crypted_password
          if params[:newpassword1] == params[:newpassword2]
            root.password = CryptUtils.one_way_crypt( params[:newpassword1] )
            root.private_key = CryptUtils.encrypt_private_key( session[:private_key], params[:newpassword1] )
            root.save
            flash[:notice] = "You successfully set the new root password"
          else
            flash[:error] = "New passwords not equal"
          end
        else
          flash[:error] = "Wrong Password"
        end
      else
        flash[:error] = "You are not root!"
      end
      redirect_to teams_path
    end    
  end
  
end
