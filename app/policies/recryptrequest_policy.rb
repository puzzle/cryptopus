class RecryptrequestPolicy < ApplicationPolicy
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

  class Scope < Scope
    def resolve
      if current_user.admin?
        @scope.all
      end
    end

    private

    def current_user
      @user
    end
  end
end
