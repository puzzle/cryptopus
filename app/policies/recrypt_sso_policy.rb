# frozen_string_literal: true

class RecryptSsoPolicy < ApplicationPolicy
  def new?
    !user.oidc? && AuthConfig.oidc_enabled?
  end

  def create?
    !user.oidc? && AuthConfig.oidc_enabled?
  end
end
