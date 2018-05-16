#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ApiController < ActionController::Base

  before_action :validate_user

  include PolicyCheck
  include SourceIpCheck
  include UserSession
  include Caching
  include ApiMessages

  protect_from_forgery with: :exception, unless: :header_auth?

  protected

  def render_json(data = nil)
    data = ActiveModelSerializers::SerializableResource.new(data).as_json
    render status: response_status, json: { data: data, messages: messages }
  end

  def team
    @team ||= ::Team.find(params[:team_id])
  end

  def user_not_authorized(_exception)
    no_access_message
    render_json
  end

  def decrypted_team_password(team)
    return plaintext_team_password(team) if active_session?

    team_password = team.decrypt_team_password(current_user, users_private_key)
    raise 'Failed to decrypt the team password' unless team_password.present?
    team_password
  end

  private

  def validate_user
    handle_pending_recrypt_request
    header_auth? ? authorize_with_headers : check_if_user_logged_in
  end

  def handle_pending_recrypt_request
    if pending_recrypt_request?
      pending_recrypt_request_message
      render_json
    end
  end

  def check_if_user_logged_in
    if current_user.nil?
      user_not_logged_in_message
      render_json
    end
  end

  def header_auth?
    return false if active_session?
    username.present?
  end

  def active_session?
    session[:private_key].present?
  end

  def authorize_with_headers
    if authenticator.auth!
      @current_user = authenticator.user
    else
      authentification_failed_message
      render_json
    end
  end

  def authenticator
    Authentication::UserAuthenticator.new(username: username, password: password_header)
  end

  def users_private_key
    current_user.decrypt_private_key(password_header)
  end

  def username
    request.headers['Authorization-User']
  end

  def password_header
    Base64.decode64(request.headers['Authorization-Password'])
  end
end
