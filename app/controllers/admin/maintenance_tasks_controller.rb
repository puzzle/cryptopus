# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Admin::MaintenanceTasksController < ApplicationController

  # GET /admin/maintenance_tasks
  def index
    authorize MaintenanceTask
    @maintenance_tasks = MaintenanceTask.list
    @maintenance_logs = Log.where(log_type: 'maintenance_task')
  end

  private
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
