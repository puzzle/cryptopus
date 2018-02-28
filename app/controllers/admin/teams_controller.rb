#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::TeamsController < ApplicationController

  # GET /teams
  def index
    skip_policy_scope
    authorize Team, :index_all?
    @teams = TeamPolicy::Scope.new(current_user, Team).resolve_all

    respond_to do |format|
      format.html
    end
  end
end
