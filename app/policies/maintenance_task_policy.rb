class MaintenanceTaskPolicy < ApplicationPolicy
  def initialize(current_user, maintenance_task)
    @current_user = current_user
    @maintenance_task = maintenance_task
  end

  def index?
    user_allowed
  end

  def execute?
    user_allowed && @maintenance_task.enabled?
  end

  def prepare?
    user_allowed && @maintenance_task.enabled?
  end

  class Scope < Scope
    def resolve
      if user_allowed
        @scope.list
      end
    end

    private

    def user_allowed
      @user.admin? || @user.conf_admin?
    end
  end

  private

  def user_allowed
    @current_user.admin? || @current_user.conf_admin?
  end
end
