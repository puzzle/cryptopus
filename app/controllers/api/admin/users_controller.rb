# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::UsersController < ApiController

  def toggle_admin
    user = User.find(params[:user_id])
    user.toggle_admin(current_user, session[:private_key])

    toggle_way = user.admin? ? 'empowered' : 'disempowered'
    add_info(t("flashes.api.admin.users.toggle.#{toggle_way}", username: user.username))
    render_json ''
  end
end
