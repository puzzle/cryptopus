# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class WizardController < ApplicationController
  before_action :redirect_if_already_set_up
  skip_before_action :validate_user, :redirect_to_wizard_if_new_setup

  def index
    skip_policy_scope
    respond_to do |format|
      format.html # index.html.haml
    end
  end

  # rubocop:disable MethodLength
  def apply
    skip_authorization
    password = params[:password]
    password_repeat = params[:password_repeat]
    if password.blank?
      flash[:error] = t('flashes.wizard.fill_password_fields')
    elsif password == password_repeat
      User::Human.create_root password
      create_session_and_redirect(password)
      return
    else
      flash[:error] = t('flashes.wizard.paswords_do_not_match')
    end
    render 'index'
  end

  private

  def create_session_and_redirect(password)
    reset_session
    user = User::Human.find_by(username: 'root')
    request.session[:user_id] = user.id
    request.session[:username] = user.username
    session[:private_key] = CryptUtils.decrypt_private_key(user.private_key, password)
    redirect_to admin_users_path
  end

  def redirect_if_already_set_up
    redirect_to login_login_path if User::Human.all.count > 0
  end
end
