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
    return false if current_user == user || user.root?

    if user.admin?
      return current_user.admin?
    end
    admin_or_conf_admin?
  end

  def destroy?
    # if user.ldap?
    #   unless ldap_connection.exists?(user.username)
    #     return current_user.admin? || current_user.conf_admin?
    #   end
    # else
    return false if user.root?

    if user.user?
      return admin_or_conf_admin?
    end
    # end
    current_user.admin?
  end

  def resetpassword?
    return false if current_user == user
    unless user.ldap?
      if user.user?
        return admin_or_conf_admin?
      end
      current_user.admin?
    end
  end

  def permitted_attributes_for_update
    return if user.ldap? || user.root?

    attrs = %i[givenname surname]

    if current_user.admin?
      attrs + %i[username]
    elsif current_user.conf_admin?
      attrs
    end
  end

  def permitted_attributes_for_create
    %i[username givenname surname password] if current_user.admin?
  end

  private

  def current_user
    @user
  end

  def user
    @record
  end
end
