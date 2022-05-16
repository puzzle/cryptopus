# frozen_string_literal: true

require 'user/api'

class Api::ApiUsers::CcliTokenController < ApiController

  # GET /api/api_users/:userId/ccli_token
  def show
    if api_user
      authorize api_user
      renewed_token = renew_token
      render_json(info: [t('flashes.api.api-users.token.renew',
                           username: api_user.username, token: renewed_token)],
                  errors: [],
                  token: renewed_token,
                  username: api_user.username)
    end
  end

  private

  def api_user
    @api_user ||= User::Api.find(user.default_ccli_user_id)
  end

  def user
    @user ||= User::Human.find(params[:id])
  end

  def renew_token
    if active_session? # api users can't have sessions
      private_key = session[:private_key]
      return api_user.renew_token_by_human(private_key)
    end

    if current_user.human?
      private_key = current_user.decrypt_private_key(password_header)
      api_user.renew_token_by_human(private_key)
    else
      api_user.renew_token(password_header)
    end
  end
end
