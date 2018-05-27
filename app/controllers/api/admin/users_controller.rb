#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::UsersController < Api::Admin::AdminController

  # DELETE /api/admin/users/1
  def destroy
    authorize user
    destroy_user
    add_info(t('flashes.api.admin.users.destroy.success', username: user.username))
    render_json ''
  end

  private

  def user
    @user ||= User.find(params[:id])
  end

  def destroy_user
    # admins cannot be removed from non-private teams
    # so set admin to false first
    user.update!(role: :user) if user.admin?
    user.destroy!
  end
end
