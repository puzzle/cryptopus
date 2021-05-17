# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::UsersController < ApiController

  self.custom_model_class = ::User::Human

  # DELETE /api/admin/users/1
  def destroy
    authorize user
    if destroy_user
      head 204
    else
      render_errors
    end
  end

  private

  def fetch_entries
    if true?(params[:locked])
      User::Human.locked
    else
      User::Human.unlocked
    end
  end

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
