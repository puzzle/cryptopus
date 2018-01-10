# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::UsersController < Api::Admin::AdminController

  def toggle_admin
    user = User.find(params[:user_id])
    user.toggle_admin(current_user, session[:private_key])

    toggle_way = user.admin? ? 'empowered' : 'disempowered'
    add_info(t("flashes.api.admin.users.toggle.#{toggle_way}", username: user.username))
    render_json ''
  end

  # DELETE /api/admin/users/1
  def destroy
    if user == current_user
      add_error(t('flashes.api.admin.users.destroy.own_user'))
    else
      destroy_user
      add_info(t('flashes.api.admin.users.destroy.success', username: user.username))
    end
    render_json ''
  end

  private

  def user
    @user ||= User.find(params[:id])
  end

  def destroy_user
    # admins cannot be removed from non-private teams
    # so set admin to false first
    user.update!(admin: false) if user.admin?
    user.destroy!
  end

end
