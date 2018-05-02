# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ApiController < ApplicationController
  protected

  def render_json(data = nil)
    data = ActiveModelSerializers::SerializableResource.new(data).as_json
    render status: response_status, json: { data: data, messages: messages }
  end

  def add_error(msg)
    messages[:errors] << msg
  end

  def add_info(msg)
    messages[:info] << msg
  end

  def team
    @team ||= ::Team.find(params[:team_id])
  end

  def user_not_authorized(_exception)
    add_error t('flashes.admin.admin.no_access')
    render_json
  end

  def plaintext_team_password(team)
    return super if active_session?

    team_password = team.decrypt_team_password(current_user, users_private_key)
    raise 'Failed to decrypt the team password' unless team_password.present?
    team_password
  end

  def current_user
    @current_user ||= super
  end

  private

  def validate_user
    if header_auth?
      redirect_if_pending_recrypt_request
      authorize_with_headers
    else
      super
    end
  end

  def header_auth?
    return false if active_session?
    username.present?
  end

  def redirect_if_pending_recrypt_request
    return unless current_user.is_a?(User::Human)
    if current_user.recryptrequests.first
      add_error('Wait for the recryption of your users team passwords')
      @response_status = 403
      render_json
    end
  end

  def authorize_with_headers
    if authenticator.auth!
      @current_user = authenticator.user
    else
      add_error('Authentification failed')
      @response_status = 401
      render_json
    end
  end

  def authenticator
    Authentication::UserAuthenticator.new(username: username, password: password_header)
  end

  def messages
    @messages ||=
      { errors: [], info: [] }
  end

  def response_status
    @response_status ? @response_status : success_or_error
  end

  def success_or_error
    messages[:errors].present? ? :internal_server_error : nil
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
