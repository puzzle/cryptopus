# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::AdminController < ApiController
  before_action :check_for_admin

  protected

  def check_for_admin
    user = User.find(session[:user_id])

    unless user.admin? || user.conf_admin?
      add_error(t('flashes.api.admin.users.no_access'))
      @response_status = 403
      render_json
    end
  end

end
