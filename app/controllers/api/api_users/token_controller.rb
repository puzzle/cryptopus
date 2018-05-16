#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'user/api'

class Api::ApiUsers::TokenController < ApiController

  # GET /api/api_users/token/1
  def show
    authorize api_user
    token = api_user.renew_token(session[:private_key])
    add_info(t('flashes.api.api-users.token.renew', username: api_user.username, token: token))
    render_json api_user
  end

  # DELETE /api/api_users/token/1
  def destroy
    authorize api_user
    api_user.update!(locked: true)
    add_info(t('flashes.api.api-users.token.invalidated', username: api_user.username))
    render_json ''
  end

  private

  def api_user
    @api ||= User::Api.find(params[:id])
  end
end
