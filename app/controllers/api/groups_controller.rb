#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::GroupsController < ApiController
  def index
    skip_policy_scope
    groups = GroupPolicy::Scope.new(current_user, Group).resolve_all
    render_json find_groups(groups)
  rescue ActionController::ParameterMissing
    render_json
  end

  private

  def find_groups(groups)
    if query_param.present?
      groups = finder(groups, query_param).apply
    end
    groups
  end

  def finder(groups, query)
    Finders::GroupsFinder.new(groups, query)
  end

  def query_param
    params[:q]
  end
end
