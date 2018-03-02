#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::AccountsController < ApiController
  def index
    skip_policy_scope
    accounts = find_accounts
    render_json accounts
  rescue ActionController::ParameterMissing
    render_json
  end

  private

  def find_accounts
    if params[:q].present?
      accounts_finder.find(current_user, query)
    else
      accounts_finder.find_by_tag(current_user, tag)
    end
  end

  def accounts_finder
    Finders::AccountsFinder.new
  end

  def query
    params.require(:q)
  end

  def tag
    params.require(:tag)
  end
end
