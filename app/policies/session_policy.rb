# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy

  def new?
    user.nil?
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
