# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTask
  class_attribute :label, :description, :hint, :task_params
  PARAM_TYPE_PASSWORD = 'password'.freeze
  PARAM_TYPE_CHECKBOX = 'check_box'.freeze
  PARAM_TYPE_NUMBER = 'number'.freeze
  PARAM_TYPE_TEXT = 'text'.freeze

  TASKS = %w[RootAsAdmin NewRootPassword].freeze
  class << self
    def list
      TASKS.collect do |t|
        constantize_class(t)
      end
    end

    def initialize_task(task_id, current_user, param_values = {})
      id = task_id.to_i
      constantize_class(TASKS[id]).new(current_user, param_values)
    end

    def constantize_class(task)
      "MaintenanceTasks::#{task}".constantize
    end
  end

  def initialize(current_user, param_values = {})
    @current_user = current_user
    @param_values = param_values
  end

  def execute
    ApplicationRecord.transaction do
      yield if block_given?
      success_log_entry('successful')
      true
    end
  rescue => e
    failed_log_entry(e)
    false
  end

  protected

  def current_user_private_key
    @param_values[:private_key]
  end

  def failed_log_entry(exception)
    create_log_entry(exception.message, 'failed')
  end

  def success_log_entry(message)
    create_log_entry(message, 'success')
  end

  def create_log_entry(message, status)
    Log.create(output: message,
               executer_id: @current_user.id,
               status: status,
               log_type: 'maintenance_task')
  end
end
