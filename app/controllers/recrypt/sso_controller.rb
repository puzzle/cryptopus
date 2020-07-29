# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Recrypt::SsoController < ApplicationController

  skip_before_action :redirect_if_no_private_key

  # GET recrypt/sso
  def new
    authorize :recryptSso
    render layout: false
  end

  # POST recrypt/sso
  def create
    authorize :recryptSso
    unless user_authenticator.keycloak_signed_in?
      return redirect_to user_authenticator.keycloak_login
    end

    pk_secret_base = keycloak_client.find_or_create_pk_secret_base(access_token)
    recrypt_private_key(
      keycloak_client.user_pk_secret(pk_secret_base, access_token)
    )
  end

  private

  def recrypt_private_key(new_password)
    if current_user.recrypt_private_key!(new_password, params[:old_password], cookies)
      current_user.update!(auth: 'keycloak', password: nil)

      reset_session_before_redirect
      return redirect_to user_authenticator.keycloak_login
    end

    flash[:error] = current_user.errors.full_messages.join
    redirect_to user_authenticator.recrypt_path
  end

  def reset_session_before_redirect
    jumpto = params[:jumpto]
    reset_session
    session[:jumpto] = jumpto
  end

  def user_authenticator
    Authentication::UserAuthenticator.init(
      username: current_user.username,
      password: params[:new_password],
      cookies: cookies
    )
  end

  def access_token
    return if cookies.nil? || cookies['keycloak_token'].nil?

    JSON.parse(cookies['keycloak_token']).try(:[], 'access_token')
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
