# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ApiController < CrudController

  skip_before_action :set_sentry_request_context
  skip_before_action :message_if_fallback
  skip_before_action :redirect_if_no_private_key, except: :logout
  skip_before_action :set_locale

  before_action :set_headers
  before_action :validate_user

  rescue_from ArgumentError, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  include ApiMessages

  protect_from_forgery with: :exception, unless: :header_auth?

  protected

  def render_json(data = nil, status = nil)
    render status: status || response_status, json: data || messages, include: '*'
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
    raise 'Failed to decrypt the team password' if team_password.blank?

    team_password
  end

  def username
    request.headers['Authorization-User']
  end

  def password_header
    Base64.decode64(request.headers['Authorization-Password'])
  end

  private

  def bad_request(exception = nil)
    if exception
      logger.debug("#{exception}:\n\t#{exception.backtrace.join("\n\t")}")
      @rescued_exception = exception
    end
    bad_request_message
    render_json
  end

  def not_found
    not_found_message
    render_json
  end

  def validate_user
    header_auth? ? authorize_with_headers : check_if_user_logged_in
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

  def authorize_with_headers
    if user_authenticator.authenticate_by_headers!
      @current_user = user_authenticator.user
    else
      authentification_failed_message
      render_json
    end
  end

  def set_headers
    response.headers['Content-Type'] = 'text/json'
    response.headers['Content-Disposition'] = "attachment; filename='"\
    + request.env['PATH_INFO'] + ".json'"
  end

  def user_authenticator
    @user_authenticator ||=
      Authentication::UserAuthenticator.init(username: username, password: password_header)
  end

  def users_private_key
    current_user.decrypt_private_key(password_header)
  end
end
