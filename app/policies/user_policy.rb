class UserPolicy < ApplicationPolicy

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def index?
    @current_user.admin?
  end

  def update?
    @current_user.admin?
  end

  def new?
    @current_user.admin?
  end

  def create?
    @current_user.admin?
  end

  def unlock?
    @current_user.admin?
  end

  def toggle_admin?
    @current_user.admin?
  end

  def destroy?
    @current_user.admin?
  end

  def resetpassword?
    @current_user.admin?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        @scope.where('ldap_uid != 0 or ldap_uid is null')
      end
    end
  end
end
