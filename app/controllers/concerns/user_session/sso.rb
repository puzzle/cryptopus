# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module UserSession::Sso
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
    before_action :redirect_if_no_private_key
    before_action :validate_user, except: [:wizard, :sso]
  end

  def validate_user
    return if current_user.present? && current_user.root?

    unless current_user.present? && Keycloak::Client.user_signed_in?
      session[:jumpto] = request.parameters
      redirect_to Keycloak::Client.url_login_redirect(session_sso_url, 'code')
    end
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

  def redirect_if_no_private_key
    if current_user.is_a?(User::Human) && !active_session?
      redirect_to recryptrequests_new_ldap_password_path
    end
  end

  def auth_provider
    Authentication::AuthProvider::Sso.new(
      username: params['username'] || Keycloak::Client.get_attribute('preferred_username'),
      password: params['password']
    )
  end

  private

  def active_session?
    session[:private_key].present?
  end
end
