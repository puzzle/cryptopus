#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::TeamlistController < ApplicationController

  # GET /teams
  def index
    skip_policy_scope
    authorize Team, :admins_list?
    @teams = TeamPolicy::Scope.new(current_user, Team).resolve_teamlist

    respond_to do |format|
      format.html
    end
  end
end
