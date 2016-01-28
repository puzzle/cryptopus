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

class LoginsController < ApplicationController
  include User::Authenticate
  before_filter :redirect_if_ldap_user, only: [:show_update_password, :update_password]
  before_filter :redirect_if_logged_in, only: [:login]

  skip_before_filter :verify_authenticity_token, only: [:authenticate]

  def login
  end

  def authenticate
    username = params[:username].strip
    password = params[:password]

    user = User.find_or_import_from_ldap(username, password)

    if user
      authenticate_user(user, password)
    else
      flash[:error] = t('flashes.logins.auth_failed')
      render action: 'login'
    end
  end

  def logout
    reset_session
    redirect_to login_login_path
  end

  def show_update_password
    render :show_update_password
  end

  def update_password
    if password_params_valid?
      current_user.update_password(params[:old_password], params[:new_password1])
      flash[:notice] = t('flashes.logins.new_password_set')
      redirect_to teams_path
    else
      render :show_update_password
    end
  end

  # POST /login/changelocale
  def changelocale
    locale = params[:new_locale]
    if locale.present?
      current_user.update_attribute(:preferred_locale, locale)
    end

    redirect_to :back
  end

  private
  def user_locked?(user)
    if user.locked?
      flash[:error] = t('flashes.logins.locked')
      render action: 'login'
      true
    end
  end

  def authenticate_user(user, password)
    return if user_locked?(user)

    if user.authenticate(password)
      begin
        create_session(user, password)
      rescue Exceptions::DecryptFailed
        redirect_to recryptrequests_path
        return
      end
      redirect_after_sucessful_login
    else
      flash[:error] = t('flashes.logins.auth_failed')
      render action: 'login'
    end
  end

  def create_session(user, password)
    user.update_info

    set_session_attributes(user, password)

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
    session[:private_key] = user.decrypt_private_key(password)
  end

  def redirect_if_ldap_user
    redirect_to search_path if current_user.auth_ldap?
  end

  def redirect_if_logged_in
    redirect_to search_path if current_user
  end

  def password_params_valid?
    unless current_user.authenticate(params[:old_password])
      flash[:error] = t('flashes.logins.wrong_password')
      return false
    end

    if params[:new_password1] != params[:new_password2]
      flash[:error] = t('flashes.logins.new_passwords.not_equal')
      return false
    end
    true
  end
end
