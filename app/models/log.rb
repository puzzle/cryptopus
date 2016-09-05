# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Log < ActiveRecord::Base
  default_scope { order('created_at DESC') }
  validates_inclusion_of :log_type, in: %w(maintenance_task)
  validates_inclusion_of :status, in: %w(failed success)
end
