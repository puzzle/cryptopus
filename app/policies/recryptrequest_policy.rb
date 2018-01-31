class RecryptrequestPolicy < ApplicationPolicy

  def initialize(current_user, recryptrequest)
    @current_user = current_user
    @recryptrequest = recryptrequest
  end

  def destroy?
    @current_user.admin?
  end

  def new_ldap_password?
    @current_user.ldap?
  end

  def recrypt?
    true
  end

  class Scope < Scope
    def initialize(current_user, scope)
      @current_user = current_user
      @scope = scope
    end

    def resolve
      if @current_user.admin?
        scope.all
      end
    end
  end
end
