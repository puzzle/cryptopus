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

  before_filter :redirect_if_ldap_user, only: [:show_update_password, :update_password]
  before_filter :redirect_if_logged_in, only: [:login]

  def login
  end

  def authenticate
    username = params[:username].strip
    password = params[:password]

    user = User.authenticate(username, password)

    if user
      begin
        create_session(user, password)
      rescue Exceptions::DecryptFailed
        redirect_to recryptrequests_path 
        return
      end
      redirect_after_sucessful_login
    else
      flash[:error] = t('flashes.logins.auth_failed')
      render :action => 'login'
    end
  end

  def logout
    reset_session
    redirect_to login_login_path
  end

  def show_update_password
  end

  # TODO update and fix tests
  def update_password
    current_password = params[:password]
    new_password = params[:newpassword1]
    # TODO password match ?
    # TODO old password valid ?
    current_user.update_password(current_password, new_password)
    flash[:notice] = t('flashes.logins.new_password_set')
    redirect_to teams_path
    # TODO render show_update_password if update fails
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
  def create_session(user, password)
    user.update_info

    set_session_attributes(user, password) #rescue decrypt_with_legacy(user)

    CryptUtils.validate_keypair( session[:private_key], user.public_key )
  end

  def redirect_after_sucessful_login
    if session[:jumpto].blank?
      redirect_to search_path
    else
      jump_to = session[:jumpto]
      session[:jumpto] = nil
      redirect_to jump_to
    end
  end

  def set_session_attributes(user, password)
    jumpto = session[:jumpto]
    reset_session
    session[:jumpto] = jumpto
    session[:username] = user.username
    session[:user_id] = user.id.to_s
    session[:private_key] = CryptUtils.decrypt_private_key(user.private_key, password)
  end

  # TODO still needed ? if yes, move to user model and test it
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

  def redirect_if_ldap_user
    redirect_to search_path if current_user.auth_ldap? 
  end

  def redirect_if_logged_in
    redirect_to search_path if current_user
  end
end
