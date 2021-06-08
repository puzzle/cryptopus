# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Recrypt::LdapController < ApplicationController
  skip_before_action :redirect_if_no_private_key

  # GET /recrypt/ldap
  def new
    authorize_action :new
  end

  # POST /recrypt/ldap
  def create
    authorize_action :create

    set_params_for_user_auth
    unless user_authenticator.authenticate!
      flash[:error] = t('activerecord.errors.models.user.new_password_invalid')
      return redirect_to user_authenticator.recrypt_path
    end

    recrypt_private_key
  end

  private

  def set_params_for_user_auth
    # set password param for authenticator
    params[:username] = current_user.username
    params[:password] = params[:new_password]
  end

  def authorize_action(action)
    authorize action, policy_class: Recrypt::LdapPolicy
  end

  def recrypt_private_key
    if current_user.recrypt_private_key!(params[:new_password], params[:old_password])
      return redirect_to session_destroy_path
    end

    flash[:error] = current_user.errors.full_messages.join
    redirect_to user_authenticator.recrypt_path
  end

end
