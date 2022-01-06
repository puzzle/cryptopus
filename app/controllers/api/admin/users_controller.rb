# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::UsersController < ApiController

  self.custom_model_class = ::User::Human

  # DELETE /api/admin/users/1
  def destroy
    ActiveRecord::Base.transaction do
      entry.update!(role: :user) if entry.admin?
      super
    end
  end

  private

  def permitted_attrs
    return [] if non_db_human_user_or_root?

    attrs = [:givenname, :surname, :default_ccli_user_id]

    if current_user.admin?
      attrs += [:username]

      attrs += [:password] if @user_human.nil?
    end
    attrs
  end

  def non_db_human_user_or_root?
    @user_human.present? && (!entry.auth_db? || entry.root?)
  end

  def build_entry
    @user_human = User::Human.create_db_user(password, model_params)
  end

  def password
    model_params[:password]
  end

  def fetch_entries
    if true?(params[:locked])
      User::Human.locked
    else
      User::Human.unlocked
    end
  end
end
