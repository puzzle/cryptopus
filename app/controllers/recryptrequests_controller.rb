# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class RecryptrequestsController < ApplicationController
  include User::Authenticate
  skip_before_action :redirect_if_no_private_key

  # GET /recryptrequests/new_ldap_password
  def new_ldap_password
    @user = current_user
  end

  #POST /recryptrequests/recrypt
  def recrypt
    if params[:forgot_password].nil?
      recrypt_private_key()
    else
      create_recrypt_request()
    end
  end

  def create_recrypt_request
    # Check if there's allready a recryptrequest
    if current_user.recryptrequests.empty?
      current_user.create_keypair(params[:new_password])
      current_user.save!

      current_user.recryptrequests.create
    end

    flash[:notice] = t('flashes.recryptrequests.wait')
    redirect_to logout_login_path
  end

  def recrypt_private_key
    if current_user.recrypt_private_key!(params[:new_password], params[:old_password])
      flash[:notice] = t('flashes.recryptrequests.recrypted')
      return redirect_to logout_login_path
    end

    flash[:error] = current_user.errors[:base][0]
    redirect_to recryptrequests_new_ldap_password_path
  end
end
