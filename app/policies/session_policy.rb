# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy

  def new?
    user.nil? && keycloak_disabled?
  end

  def fallback?
    user.nil? && keycloak_enabled?
  end

  def sso?
    user.nil? && keycloak_enabled?
  end

  def create?
    user.nil?
  end

  def destroy?
    user.present?
  end

  def show_update_password?
    user.present? && !user.ldap?
  end

  def update_password?
    user.present? && !user.ldap?
  end

  def changelocale?
    user.present?
  end

end
