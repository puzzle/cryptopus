# frozen_string_literal: true

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

  def maintenance_task
    @record
  end
end
