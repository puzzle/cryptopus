class Log < ActiveRecord::Base
  default_scope {order('created_at DESC')}
  validates_inclusion_of :log_type, in: %w(maintenance_task)
  validates_inclusion_of :status, in: %w(failed success)
end
