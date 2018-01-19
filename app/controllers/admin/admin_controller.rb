# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::AdminController < ApplicationController

  protected

  def check_for_admin
    user = User.find(session[:user_id])

    unless user.admin?
      flash[:error] = t('flashes.admin.admin.no_access')
      redirect_to teams_path
    end
  end
end
