# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Team::MembersController < ApiController

  def index
    members = team.members
    render_json members
  end

  def candidates
    candidates = team.member_candidates
    render_json candidates
  end

  def create
  end

  private
  def team
    @team ||= ::Team.find(params[:team_id])
  end

end
