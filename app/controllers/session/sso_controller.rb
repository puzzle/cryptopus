# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Session::SsoController < SessionController

  before_action :keycloak_cookie

  def create
    cookies.permanent[:keycloak_token] = user_authenticator.token(params) if params[:code].present?
    unless user_authenticator.authenticate!
      return redirect_to user_authenticator.keycloak_login
    end

    create_session(keycloak_client.user_pk_secret)
    last_login_message
    redirect_after_sucessful_login
  end

  def inactive
    flash[:notice] = t('session.sso.inactive.inactive')
  end

  private

  def authorize_action
    authorize :sso
  end

  def keycloak_cookie
    Keycloak.proc_cookie_token = -> { cookies.permanent[:keycloak_token] }
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
