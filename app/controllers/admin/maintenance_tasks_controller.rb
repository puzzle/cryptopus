# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::MaintenanceTasksController < ApplicationController

  # GET /admin/maintenance_tasks
  def index
    authorize MaintenanceTask
    @maintenance_tasks = policy_scope(MaintenanceTask)
    @maintenance_logs = Log.where(log_type: 'maintenance_task')
  end

  # GET /admin/maintenance_tasks/1/prepare
  def prepare
    raise routing_error unless maintenance_task.prepare?
    authorize maintenance_task

    flash[:notice] = maintenance_task.hint
    flash[:error] = maintenance_task.error
  end

  # POST /admin/maintenance_tasks/1/execute
  def execute
    raise routing_error unless maintenance_task
    authorize maintenance_task

    set_task_attributes

    result = maintenance_task.execute
    result ? success_message : error_message

    if result && template_exists?(partial)
      render partial
    else
      redirect_to admin_maintenance_tasks_path
    end
  end

  private

  def set_task_attributes
    maintenance_task.executer = current_user
    maintenance_task.param_values = param_values
  end

  def partial
    "admin/maintenance_tasks/#{maintenance_task.name}/result.html.haml"
  end

  def success_message
    flash[:notice] = t('flashes.admin.maintenance_tasks.succeed')
  end

  def error_message
    flash[:error] = t('flashes.admin.maintenance_tasks.failed')
  end

  def maintenance_task
    @maintenance_task ||= MaintenanceTask.find(params[:id])
  end

  def param_values
    param_values = { private_key: session[:private_key] }
    param_values.merge!(task_params)
  end

  def task_params
    return {} unless params[:task_params]
    params.require(:task_params).
      permit(:retype_password, :root_password)
  end

  def routing_error
    ActionController::RoutingError.new('Not Found')
  end

end
