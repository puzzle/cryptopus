class MaintenanceTaskPolicy < ApplicationPolicy
  def index?
    admin_or_conf_admin?
  end

  def execute?
    admin_or_conf_admin? && maintenance_task.enabled?
  end

  def prepare?
    admin_or_conf_admin? && maintenance_task.enabled?
  end

  private

  def current_user
    @user
  end

  def maintenance_task
    @record
  end

  class Scope < Scope
    def resolve
      @scope.list if admin_or_conf_admin?
    end
  end
end
