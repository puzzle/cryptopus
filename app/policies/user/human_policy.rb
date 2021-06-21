# frozen_string_literal: true

class User::HumanPolicy < ApplicationPolicy
  def index?
    admin_or_conf_admin?
  end

  def update?
    return false unless AuthConfig.db_enabled?
    return false if user.ldap? || user.root?

    if user.user?
      return admin_or_conf_admin?
    end

    current_user.admin?
  end

  def edit?
    return false if own_user?

    if user.auth_db?
      if user.user?
        return admin_or_conf_admin?
      end

      current_user.admin?
    end
  end

  def new?
    AuthConfig.db_enabled? && admin_or_conf_admin?
  end

  def create?
    AuthConfig.db_enabled? && admin_or_conf_admin?
  end

  def unlock?
    !AuthConfig.oidc_enabled? && admin_or_conf_admin?
  end

  def update_role?
    return false if own_user? || user.root?

    if user.admin?
      return current_user.admin?
    end

    admin_or_conf_admin?
  end

  def destroy?
    return false if user.root? || own_user?

    if user.user?
      return admin_or_conf_admin?
    end

    current_user.admin?
  end

  def resetpassword?
    return false unless AuthConfig.db_enabled?
    return false if own_user?

    unless user.ldap?
      if user.user?
        return admin_or_conf_admin?
      end

      current_user.admin?
    end
  end

  private

  def current_user
    @user
  end

  def user
    @record
  end

  def own_user?
    current_user == user
  end
end
