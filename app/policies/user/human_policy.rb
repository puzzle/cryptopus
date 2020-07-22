# frozen_string_literal: true

class User::HumanPolicy < ApplicationPolicy
  def index?
    admin_or_conf_admin?
  end

  def update?
    return if user.ldap? || user.root?
    if user.user?
      return admin_or_conf_admin?
    end

    current_user.admin?
  end

  def edit?
    return false if own_user?

    unless user.ldap?
      if user.user?
        return admin_or_conf_admin?
      end

      current_user.admin?
    end
  end

  def new?
    admin_or_conf_admin?
  end

  def create?
    admin_or_conf_admin?
  end

  def unlock?
    admin_or_conf_admin?
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
    return false if own_user?

    unless user.ldap?
      if user.user?
        return admin_or_conf_admin?
      end

      current_user.admin?
    end
  end

  def permitted_attributes_for_update
    return if !user.auth_db? || user.root?

    attrs = [:givenname, :surname]

    if current_user.admin?
      attrs + [:username]
    elsif current_user.conf_admin?
      attrs
    end
  end

  def permitted_attributes_for_create
    [:username, :givenname, :surname, :password] if current_user.admin?
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
