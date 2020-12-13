# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Recrypt::OidcController < ApplicationController

  skip_before_action :redirect_if_no_private_key
  skip_before_action :validate_user
  before_action :assert_pending_recrypt

  # GET recrypt/oidc
  def new
    authorize_action :new
    render layout: false
  end

  # POST recrypt/oidc
  def create
    authorize_action :create
    user_passphrase = session[:oidc_recrypt_user_passphrase]
    recrypt_private_key(user_passphrase)
  end

  private

  def authorize_action(action)
    authorize action, policy_class: Recrypt::OidcPolicy
  end

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

  def current_user
    @current_user ||= User::Human.find(session[:oidc_recrypt_user_id])
  end

  def assert_pending_recrypt
    redirect_to root_path unless current_user
  end
end
