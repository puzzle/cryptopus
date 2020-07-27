# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Session::SsoController < SessionController

  layout 'session', only: :inactive

  def create
    cookies.permanent[:keycloak_token] = user_authenticator.token(params) if params[:code].present?
    if cookies[:keycloak_token].nil?
      return redirect_to user_authenticator.keycloak_login
    end

    unless user_authenticator.authenticate!
      return redirect_to user_authenticator.keycloak_login
    end

    unless create_session(keycloak_client.user_pk_secret(secret: nil, cookies: cookies))
      return redirect_if_decryption_error
    end

    last_login_message
    redirect_after_sucessful_login
  end

  def inactive
    flash[:notice] = t('session.sso.inactive.inactive')
  end

  private

  def redirect_if_decryption_error
    return redirect_to user_authenticator.recrypt_path unless current_user.keycloak?

    reset_session_before_redirect
    redirect_to user_authenticator.keycloak_login
  end

  def authorize_action
    authorize :sso
  end

  def reset_session_before_redirect
    jumpto = params[:jumpto]
    reset_session
    session[:jumpto] = jumpto
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
