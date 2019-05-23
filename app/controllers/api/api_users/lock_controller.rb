# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'user/api'

class Api::ApiUsers::LockController < ApiController

  # GET /api/api_users/1/lock
  def create
    authorize api_user, :lock?
    api_user.lock
    add_info(t('flashes.api.api-users.lock', username: api_user.username))
    render_json ''
  end

  # GET /api/api_users/1/unlock
  def destroy
    authorize api_user, :unlock?
    api_user.unlock
    add_info(t('flashes.api.api-users.unlock', username: api_user.username))
    render_json ''
  end

  private

  def api_user
    @api_user ||= User::Api.find(params[:id])
  end
end
