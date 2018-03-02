#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::AccountsController < ApiController
  def index
    skip_authorization
    skip_policy_scope
    accounts = accounts_finder.find(current_user, term)
    render_json accounts
  rescue ActionController::ParameterMissing
    render_json
  end

  private

  def accounts_finder
    Finders::AccountsFinder.new
  end

  def term
    params.require(:q)
  end
end
