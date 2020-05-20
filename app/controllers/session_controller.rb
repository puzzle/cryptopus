# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class SessionController < ApplicationController
  before_action :authorize_action
  before_action :skip_authorization, only: [:create, :new, :destroy, :sso]
  before_action :check_root_source_ip, only: :fallback

  # it's save to disable this for authenticate since there is no logged in session active
  # in this case.
  # caused problem with login form since the server side session is getting invalid after
  # configured timeout.
  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :validate_user, only: [:new, :create, :destroy]
  skip_before_action :redirect_if_no_private_key, only: [:destroy, :new]


  def create
    unless auth_provider.authenticate!
      flash[:error] = t('flashes.session.auth_failed')
      return redirect_to session_new_path
    end

    unless create_session(auth_provider.user, params[:password])
      return redirect_to recryptrequests_new_ldap_password_path
    end

    last_login_message
    check_password_strength
    redirect_after_sucessful_login
  end

  def fallback
    render :new
  end

  def sso
    token = Keycloak::Client.get_token_by_code(params[:code], session_sso_url)
    cookies.permanent[:keycloak_token] = token
    auth_provider.authenticate!
    return update_token if Keycloak::Client.get_attribute('pk_secret_base').nil?

    unless create_session(auth_provider.user, CryptUtils.pk_secret)
      return redirect_to recryptrequests_new_ldap_password_path
    end

    last_login_message
    redirect_after_sucessful_login
  end

  def destroy
    Keycloak::Client.logout if AuthConfig.keycloak_enabled? && !current_user.root?
    flash_notice = params[:autologout] ? t('session.destroy.expired') : flash[:notice]
    jumpto = params[:jumpto]
    reset_session
    session[:jumpto] = jumpto
    flash[:notice] = flash_notice
    redirect_to session_new_path
  end

  def show_update_password
    render :show_update_password
  end

  def update_password
    if password_params_valid?
      current_user.update_password(params[:old_password],
                                   params[:new_password1])
      flash[:notice] = t('flashes.session.new_password_set')
      redirect_to teams_path
    else
      render :show_update_password
    end
  end

  # POST /session/locale
  def changelocale
    locale = params.permit(:new_locale)[:new_locale]
    if locale.present?
      current_user.update!(preferred_locale: locale)
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def last_login_message
    flash_message = Flash::LastLoginMessage.new(session)
    flash[:notice] = flash_message.message if flash_message
  end

  def check_password_strength
    strength = PasswordStrength.test(params[:username], params[:password])

    if strength.weak? || !strength.valid?
      flash[:alert] = t('flashes.session.weak_password')
    end
  end

  def create_session(user, password)
    begin
      set_session_attributes(user, password)
      auth_provider.update_user_info(request.remote_ip)
      CryptUtils.validate_keypair(session[:private_key], user.public_key)
    rescue Exceptions::DecryptFailed
      return false
    end
    true
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
    session[:last_login_at] = user.last_login_at
    session[:last_login_from] = user.last_login_from
  end

  def password_params_valid?
    unless auth_provider.authenticate!
      flash[:error] = t('flashes.session.wrong_password')
      return false
    end

    if params[:new_password1] != params[:new_password2]
      flash[:error] = t('flashes.session.new_passwords.not_equal')
      return false
    end
    true
  end

  def authorize_action
    authorize :session
  end
end
