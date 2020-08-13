# frozen_string_literal: true

require 'user/api'

class Api::ApiUsers::CcliTokenController < ApiController

  # GET /api/api_users/:id/ccli_token
  def show
    authorize api_user
    render_json(info: [t('flashes.api.api-users.ccli_login.copied')],
                errors: [],
                ccli_token: ccli_token,
                base_url: request.base_url)
  end

  def api_user
    @api_user ||= User::Api.find(params[:id])
  end

  def renew_token
    if active_session?
      api_user.renew_token(session[:private_key])
    else
      password = password_header
      private_key = current_user.decrypt_private_key(password)
      api_user.renew_token(private_key)
    end
  end

  def ccli_token
    Base64.encode64("#{api_user.username};#{renew_token}")
  end
end
