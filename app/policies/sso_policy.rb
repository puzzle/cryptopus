# frozen_string_literal: true

class SsoPolicy < ApplicationPolicy

  def create?
    AuthConfig.keycloak_enabled?
  end

  def inactive?
    user.nil? && AuthConfig.keycloak_enabled?
  end
end
