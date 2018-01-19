class MaintenanceTaskPolicy < ApplicationPolicy
  def initialize(current_user, maintenance_task)
    @current_user = current_user
    @maintenance_task = maintenance_task
  end

  def index?
    @current_user.admin?
  end

  def execute?
    @current_user.admin?
  end

  def prepare?
    @current_user.admin?
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        @scope.list
      end
    end
  end
end
