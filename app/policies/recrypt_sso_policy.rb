# frozen_string_literal: true

class RecryptSsoPolicy < ApplicationPolicy
  def new?
    !user.keycloak? && AuthConfig.keycloak_enabled?
  end

  def create?
    !user.keycloak? && AuthConfig.keycloak_enabled?
  end
end
