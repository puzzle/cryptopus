#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'user/api'

class Api::ApiUsers::TokenController < ApiController

  # GET /api/api_users/token/1
  def show
    authorize api
    token = api.renew_token(session[:private_key])
    add_info(t('flashes.api.api-users.token.renew', username: api.username, token: token))
    render_json api
  end

  # DELETE /api/api_users/token/1
  def destroy
    authorize api
    api.update!(locked: true)
    add_info(t('flashes.api.api-users.token.invalidated', username: api.username))
    render_json ''
  end

  private

  def api
    @api ||= User::Api.find(params[:id])
  end
end
