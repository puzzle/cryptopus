class RecryptrequestPolicy < ApplicationPolicy
  def index?
    current_user.admin?
  end

  def destroy?
    current_user.admin?
  end

  def new_ldap_password?
    current_user.ldap?
  end

  def recrypt?
    true
  end

  private

  def current_user
    @user
  end
end
