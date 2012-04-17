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
  def init_root_session
    session[:username] = "root"
    @password = params[:password]
    session[:uid] = "0"
  end
  
public

  def login
    if User.find( :first, :conditions => ["uid = ?", "0"] ).nil?
      flash[:notice] = 'Welcome to Cryptopus, First you have to create a new Root account. Please enter "root" as username and enter a new password'
    end
    if session[:uid]
      redirect_to teams_path
    end
  end 
    
  def authenticate
    access_granted = false
    
    if (params[:username] != "") \
    && (params[:password] != "") \
    && (params[:username] != nil) \
    && (params[:password] != nil)
      
      # Validate Root Login
      if params[:username] == "root"
        crypted_password = CryptUtils.one_way_crypt( params[:password] )
        root = User.find( :first, :conditions => ["uid = ?", "0"] )
        
        #if root is nil, we don't have yet a root user
        if (root.nil?)||(root.password==crypted_password)
          init_root_session
          access_granted = true
        end
      else
        # Validate User LDAP Login
        if LdapTools.ldap_login(params[:username], params[:password])
          session[:username] = params[:username]
          @password = params[:password]
          session[:uid] = String.new( LdapTools.get_uid_by_username( params[:username] ) )
          if session[:uid] == nil
            flash[:error] = 'Could not find the UID for the user'
            render :action => 'login'
            return
          end
          access_granted = true
        end
      end
      
      if access_granted
        # check if the user is in the database
        user = User.find( :first, :conditions => ["uid = ?", session[:uid]] )
        unless user.nil?
          begin
            session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, @password )
          rescue
            begin
              # This tries to decrypt with legacy crypt methods and migrates to the current method
              session[:private_key] = CryptUtilsLegacy.decrypt_private_key( user.private_key, @password )
              user.private_key = CryptUtils.encrypt_private_key( session[:private_key], @password )
              user.save
            rescue
              redirect_to recryptrequests_path
              return
            end
          end
          user.last_login_at = Time.now
          user.save
          if session[:jumpto].nil? or session[:jumpto].empty?
            redirect_to teams_path
          else
            jump_to = session[:jumpto]
            session[:jumpto] = nil
            redirect_to jump_to
          end
          return
          
        # If the user does not exists in the database, 
        # we create him and a new keypair for him.
        else
          keypair = CryptUtils.new_keypair
          session[:private_key] = CryptUtils.get_private_key_from_keypair( keypair )
          session[:public_key] = CryptUtils.get_public_key_from_keypair( keypair )
          encrypted_private_key = CryptUtils.encrypt_private_key( session[:private_key], @password )
          user = User.new
          user.uid = session[:uid]
          user.public_key = session[:public_key]
          user.private_key = encrypted_private_key
          # Set the password for the user "root" 
          if session[:uid] == "0"
            crypted_password = CryptUtils.one_way_crypt( params[:password] )
            user.password = crypted_password
            user.admin = true
          end
          user.last_login_at = Time.now
          user.save
          render :action => 'newuser'
          return
        end
         
      end
    end
    flash[:error] = 'Enter a correct username and password or check the LDAP Settings'
    render :action => 'login'
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
