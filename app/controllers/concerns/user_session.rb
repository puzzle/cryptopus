# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module UserSession
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
  end

  def pending_recrypt_request?
    return false unless current_user.is_a?(User::Human)
    if current_user.recryptrequests.first
      return true
    end

    false
  end

  def current_user
    @current_user ||= (User::Human.find(session[:user_id]) if session[:user_id])
  end

  def plaintext_team_password(team)
    raise 'You have no access to this team' unless team.teammember?(current_user.id)

    private_key = session[:private_key]
    plaintext_team_password = team.decrypt_team_password(current_user, private_key)
    raise 'Failed to decrypt the team password' unless plaintext_team_password

    plaintext_team_password
  end
end
