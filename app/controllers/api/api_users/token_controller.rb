# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'user/api'

class Api::ApiUsers::TokenController < ApiController

  # GET /api/api_users/:id/token
  def show
    authorize api_user
    renewed_token = renew_token
    render_json(info: [t('flashes.api.api-users.token.renew',
                         username: api_user.username, token: renewed_token)],
                errors: [],
                token: renewed_token,
                username: api_user.username)
  end

  # DELETE /api/api_users/:id/token
  def destroy
    authorize api_user
    api_user.update!(locked: true)
    add_info(t('flashes.api.api-users.token.invalidated'))
    render_json
  end

  private

  def api_user
    @api_user ||= User::Api.find(params[:id])
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
