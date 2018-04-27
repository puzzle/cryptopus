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
    if api_access?
      redirect_if_pending_recrypt_request
      authorize_with_headers
    else
      super
    end
  end

  def api_access?
    return false if active_session?
    username.present?
  end

  def redirect_if_pending_recrypt_request
    user = authenticator.user.is_a?(User::Api) ? authenticator.user.human_user : authenticator.user
    if user.recryptrequests.first
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
    Authentication::UserAuthenticator.new(username: username, password: password)
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
    current_user.decrypt_private_key(password)
  end

  def username
    request.env['Authorization-User']
  end

  def password
    Base64.decode64(request.env['Authorization-Password'])
  end
end
