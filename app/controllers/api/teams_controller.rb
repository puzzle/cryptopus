# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::TeamsController < ApiController

  def teammember_candidates
    candidates = team.teammember_candidates
    render_json candidates
  end

  private

  def team
    @team ||= Team.find(params[:id])
  end

end
