# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ApiController < ApplicationController

  class_attribute :api_token_accessible

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

  private

  def authorize
    if api_token_access?
      authorize_by_token
    else
      super
    end
  end

  def api_token_access?
    request.env['HTTP_API_USER'].present?
  end

  def accessible_by_api_token?
    api_token_accessible &&
      api_token_accessible.include?(action_name.to_sym)
  end

  def authorize_by_token
    if accessible_by_api_token? && api_token_authenticator.auth!
      @current_user = api_token_authenticator.user
    else
      render 401
    end
  end

  def api_token_authenticator
    Authentication::ApiTokenAuthenticator.new(params)
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

  protected

  def user_not_authorized(_exception)
    add_error t('flashes.admin.admin.no_access')
    render_json && return
  end

end
