class Admin::MaintenanceTasksController < Admin::AdminController

  # GET /admin/maintenance_tasks
  def index
    @maintenance_tasks = MaintenanceTask.list
    @maintenance_logs = Log.where(log_type: 'maintenance_task')
  end

  # GET /admin/maintenance_tasks/1/prepare
  def prepare
    task = MaintenanceTask::TASKS[params[:id].to_i]
    @maintenance_task = MaintenanceTask.constantize_class(task)
  end

  # POST /admin/maintenance_tasks/1/execute
  def execute
    param_values = { private_key: session[:private_key] }

    param_values.merge!(params[:task_params])
    task = MaintenanceTask.initialize_task(params[:id], current_user, param_values)

    if task.execute
      flash[:notice] = t('flashes.admin.maintenance_tasks.succeed')
      task.success_log_entry('successful')
    else
      flash[:error] = t('flashes.admin.maintenance_tasks.failed')
    end
    redirect_to admin_maintenance_tasks_path
  end
end