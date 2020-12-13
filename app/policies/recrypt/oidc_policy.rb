# frozen_string_literal: true

class Recrypt::OidcPolicy < ApplicationPolicy
  def new?
    !user.oidc? && AuthConfig.oidc_enabled?
  end

  def create?
    !user.oidc? && AuthConfig.oidc_enabled?
  end
end
