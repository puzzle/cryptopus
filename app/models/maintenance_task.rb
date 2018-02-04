# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTask
  class_attribute :label, :description, :hint, :task_params, :error, :id
  PARAM_TYPE_PASSWORD = 'password'.freeze
  PARAM_TYPE_CHECKBOX = 'check_box'.freeze
  PARAM_TYPE_NUMBER = 'number'.freeze
  PARAM_TYPE_TEXT = 'text'.freeze

  TASKS = %w[RootAsAdmin RemovedLdapUsers].freeze

  class << self
    def list
      TASKS.collect do |t|
        task = constantize_class(t).new
        task if task.enabled?
      end.compact
    end

    def find(id)
      list.find { |task| task.id == id.to_i }
    end

    def constantize_class(task)
      "MaintenanceTasks::#{task}".constantize
    end

  end

  attr_accessor :executer, :param_values

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

  def name
    self.class.name.split('::').last.underscore
  end

  def prepare?
    task_params.present?
  end

  def enabled?
    true
  end

  def policy_class
    MaintenanceTaskPolicy
  end

  protected

  def failed_log_entry(exception)
    create_log_entry(exception.message, 'failed')
  end

  def success_log_entry(message)
    create_log_entry(message, 'success')
  end

  def create_log_entry(message, status)
    Log.create(output: message,
               executer_id: executer.id,
               status: status,
               log_type: 'maintenance_task')
  end
end
