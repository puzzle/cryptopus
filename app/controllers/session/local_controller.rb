# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Session::LocalController < SessionController

  def create
    unless user_authenticator.authenticate!(allow_root: true)
      flash[:error] = t('flashes.session.auth_failed')
      return redirect_to local_path
    end

    unless create_session(params[:password])
      return redirect_to user_authenticator.recrypt_path
    end

    last_login_message
    check_password_strength
    redirect_after_sucessful_login
  end

  private

  def check_source_ip
    unless ip_checker.private_ip?
      flash[:error] = t('flashes.session.wrong_root')
      render layout: false, file: 'public/401.html', status: :unauthorized
    end
  end

  def authorize_action
    authorize :local
  end

  def user_authenticator
    Authentication::UserAuthenticator::Db.new(
      username: params[:username], password: params[:password]
    )
  end
end
