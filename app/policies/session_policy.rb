# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy

  def new?
    user.nil?
  end

  def oidc?
    user.nil? && AuthConfig.oidc_enabled?
  end

  def local?
    user.nil?
  end

  def root?
    user.nil?
  end

  def create?
    user.nil?
  end

  def destroy?
    user.present?
  end

  def show_update_password?
    user.present? && user.auth_db?
  end

  def update_password?
    user.present? && user.auth_db?
  end

  def changelocale?
    user.present?
  end
end
