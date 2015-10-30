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
  def login
    if session[:username]
      redirect_to teams_path
    end
  end

  def authenticate
    username = params[:username].strip
    password = params[:password]

    begin
      check_userdata(username, password)
    rescue Exceptions::UserCreationFailed, Exceptions::AuthenticationFailed
      flash[:error] = t('flashes.logins.auth_failed')
      render :action => 'login'
      return
    end

    begin
      create_session(username, password)
    rescue Exceptions::DecryptFailed
      redirect_to recryptrequests_path
      return
    end
    redirect
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
    user = User.find( session[:user_id] )
    if request.get?
      isDBUser(user, true)
    else
      if isDBUser(user, false) && areValidPasswords(user)
        changePassword(user)
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

  private
  def create_session(username, password)
    user = User.find_by_username username
    user.update_info

    set_session_attributes(user, password) rescue decrypt_with_legacy(user)

    CryptUtils.validate_keypair( session[:private_key], user.public_key )
  end

  def changePassword(user)
    user.password = CryptUtils.one_way_crypt( params[:newpassword1] )
    user.private_key = CryptUtils.encrypt_private_key( session[:private_key], params[:newpassword1] )
    user.save
    flash[:notice] = t('flashes.logins.new_password_set')
  end

  def isDBUser(user, redirect)
    unless user.auth_db?
      flash[:error] = t('flashes.logins.not_local')
      redirect_to teams_path if redirect
      return false
    end
    return true
  end

  def areValidPasswords(user)
    crypted_password = CryptUtils.one_way_crypt( params[:oldpassword] )

    if user.password != crypted_password
      flash[:error] = t('flashes.logins.wrong_password')
      return false
    end

    if params[:newpassword1] != params[:newpassword2]
      flash[:error] = t('flashes.logins.new_passwords.not_equal')
      return false
    end
    return true
  end

  def redirect
    if session[:jumpto].nil? or session[:jumpto].empty?
      redirect_to search_path
    else
      jump_to = session[:jumpto]
      session[:jumpto] = nil
      redirect_to jump_to
    end
  end

  def check_userdata(username, password)
      if(User.find_by_username(username).nil?) #TODO && check if ldap is activated
        User.create_from_external_auth username, password
      else
        User.authenticate username, password
      end
  end

  def set_session_attributes(user, password)
    jumpto = session[:jumpto]
    reset_session
    session[:jumpto] = jumpto
    session[:username] = user.username
    session[:user_id] = user.id.to_s
    session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, password )
  end

  def decrypt_with_legacy(user)
    begin
      # This tries to decrypt with legacy crypt methods and migrates to the current method
      session[:private_key] = CryptUtilsLegacy.decrypt_private_key( user.private_key, password )
      user.private_key = CryptUtils.encrypt_private_key( session[:private_key], password )
      user.save
    rescue
      raise Exceptions::DecryptFailed
    end
  end
end
