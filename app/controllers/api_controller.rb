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
    return super if session[:private_key].present?

    raise 'You have no access to this team' unless team.teammember?(current_user.id)

    private_key = current_user.decrypt_private_key(request.env['HTTP_API_TOKEN'])
    plaintext_team_password = team.decrypt_team_password(current_user, private_key)
    raise 'Failed to decrypt the team password' unless plaintext_team_password
    plaintext_team_password
  end
  
  def current_user
    # falsch?
    @current_user ||= super
  end

  private

   def validate_user
     if api_token_access?
       authorize_by_token
     else
       super
     end
   end

  def api_token_access?
    request.env['HTTP_API_USER'].present?
  end

  def authorize_by_token
    if api_user_authenticator.auth!
      @current_user = api_user_authenticator.user
    else
      render 401
    end
  end

  def api_user_authenticator
    Authentication::ApiUserAuthenticator.new(request.headers)
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

end
