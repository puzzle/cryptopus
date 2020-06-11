# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class RecryptrequestsController < ApplicationController
  skip_before_action :redirect_if_no_private_key

  # GET /recryptrequests/new_ldap_password
  def new_ldap_password
    authorize Recryptrequest
  end

  # POST /recryptrequests/recrypt
  def recrypt
    authorize Recryptrequest

    unless user_authenticator.authenticate!
      flash[:error] = t('activerecord.errors.models.user.new_password_invalid')
      return redirect_to recryptrequests_new_ldap_password_path
    end

    if params[:forgot_password]
      create_recrypt_request
    else
      recrypt_private_key
    end
  end

  private

  def create_recrypt_request
    # Check if there's already a recryptrequest
    if current_user.recryptrequests.empty?
      current_user.create_keypair(params[:new_password])
      current_user.save!

      current_user.recryptrequests.create
    end

    flash[:notice] = t('flashes.recryptrequests.wait')
    redirect_to session_destroy_path
  end

  def recrypt_private_key
    if current_user.recrypt_private_key!(params[:new_password], params[:old_password])
      flash[:notice] = t('flashes.recryptrequests.recrypted')
      return redirect_to session_destroy_path
    end

    flash[:error] = current_user.errors.full_messages.join
    redirect_to recryptrequests_new_ldap_password_path
  end

  def user_authenticator
    Authentication::UserAuthenticator.init(
      username: current_user.username,
      password: params[:new_password]
    )
  end
end
