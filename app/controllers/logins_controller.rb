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

class LoginsController < ApplicationController

private

  def create_session(user, password)
    jumpto = session[:jumpto]
    reset_session
    session[:jumpto] = jumpto
    session[:username] = user.username
    session[:user_id] = user.id.to_s
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
    CryptUtils.validate_keypair( session[:private_key], user.public_key )
  end

public

  def login
    unless User.find_by_uid(0)
      flash[:notice] = t('flashes.logins.welcome')
    end
    if session[:username]
      redirect_to teams_path
    end
  end

  def authenticate
    begin
      begin
        username = params[:username].strip
        password = params[:password]
        User.authenticate username, password
      rescue Exceptions::UserDoesNotExist
        if username == 'root'
          User.create_root password
        else
          User.create_from_external_auth username, password
        end
      end
    rescue Exceptions::UserCreationFailed, Exceptions::AuthenticationFailed
      flash[:error] = t('flashes.logins.auth_failed')
      render :action => 'login'
      return
    end

    begin
      @user = User.find_by_username username
      @user.update_info
      create_session(@user, password)
    rescue Exceptions::DecryptFailed
      redirect_to recryptrequests_path
      return
    end

    if session[:jumpto].nil? or session[:jumpto].empty?
      redirect_to search_path
    else
      jump_to = session[:jumpto]
      session[:jumpto] = nil
      redirect_to jump_to
    end
    return
  end

  def logout
    reset_session
    redirect_to login_login_path
    return
  end

  def noaccess
    @message = "sorry"
    if params[:message]
      @message = params[:message]
    end
  end

  def pwdchange
    if request.get?
      unless User.find( session[:user_id] ).auth_db?
        flash[:error] = t('flashes.logins.only_local')
        redirect_to teams_path
      end
    else
      user = User.find( session[:user_id] )

      if user.auth_db?
        crypted_password = CryptUtils.one_way_crypt( params[:oldpassword] )
        if user.password == crypted_password
          if params[:newpassword1] == params[:newpassword2]
            user.password = CryptUtils.one_way_crypt( params[:newpassword1] )
            user.private_key = CryptUtils.encrypt_private_key( session[:private_key], params[:newpassword1] )
            user.save
            flash[:notice] = t('flashes.logins.new_password_set')
          else
            flash[:error] = t('flashes.logins.new_passwords.not_equal')
          end
        else
          flash[:error] = t('flashes.logins.wrong_password')
        end
      else
        flash[:error] = t('flashes.logins.not_local')
      end
      redirect_to teams_path
    end
  end

  # POST /login/changelocale
  def changelocale
    locale = params[:locale]
    user = User.find( session[:user_id] )
    user.preferred_locale = locale
    user.save

    redirect_to :back
  end

end
