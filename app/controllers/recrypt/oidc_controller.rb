# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Recrypt::OidcController < ApplicationController

  skip_before_action :redirect_if_no_private_key

  # GET recrypt/oidc
  def new
    authorize :recryptSso
    render layout: false
  end

  # POST recrypt/oidc
  def create
    authorize :recryptSso

    user_passphrase = session.delete(:oidc_recrypt_user_passphrase)
    recrypt_private_key(user_passphrase)
  end

  private

  def recrypt_private_key(new_password)
    if current_user.recrypt_private_key!(new_password, params[:old_password])
      current_user.update!(auth: 'oidc', password: nil)

      reset_session
      redirect_to root_path
    else
      flash[:error] = current_user.errors.full_messages.join
      redirect_to recrypt_oidc_path
    end
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
