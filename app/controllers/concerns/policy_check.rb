#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module PolicyCheck
  extend ActiveSupport::Concern

  # includes pundit, a scaleable authorization system
  include Pundit

  included do
    # verifies that authorize has been called in every action
    after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: 'pundit', default: :default
    redirect_to teams_path
  end
end
