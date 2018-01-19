# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Team::GroupsController < ApiController

  def index
    groups = GroupPolicy::Scope.new(current_user, team).resolve
    render_json groups
  end

end
