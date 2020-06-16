# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module UserSession
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
    before_action :redirect_if_no_private_key
    before_action :validate_user, except: :wizard
  end

  def validate_user
    handle_pending_recrypt_request
    unless user_authenticator.user_logged_in?(session)
      session[:jumpto] = request.fullpath
      redirect_to user_authenticator.login_path
    end
  end

  def current_user
    @current_user ||= (User::Human.find(session[:user_id]) if session[:user_id])
  end

  def plaintext_team_password(team)
    raise 'You have no access to this team' unless team.teammember?(current_user.id)

    private_key = session[:private_key]
    plaintext_team_password = team.decrypt_team_password(current_user, private_key)
    raise 'Failed to decrypt the team password' unless plaintext_team_password

    plaintext_team_password
  end

  # redirect if its not possible to decrypt user's private key
  def redirect_if_no_private_key
    if current_user.is_a?(User::Human) && !active_session?
      redirect_to user_authenticator.recrypt_path
    end
  end

  def user_authenticator
    Authentication::UserAuthenticator.init(
      username: params['username'], password: params['password']
    )
  end

  private

  def handle_pending_recrypt_request
    if pending_recrypt_request?
      pending_recrypt_request_message
      redirect_to session_destroy_path
    end
  end

  def pending_recrypt_request?
    current_user.is_a?(User::Human) && current_user.recryptrequests.first
  end

  def active_session?
    session[:private_key].present?
  end
end
