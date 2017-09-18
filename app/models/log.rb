# encoding: utf-8

# == Schema Information
#
# Table name: logs
#
#  id          :integer          not null, primary key
#  output      :string
#  status      :string
#  log_type    :string
#  executer_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Log < ApplicationRecord
  default_scope { order('created_at DESC') }
  validates :log_type, inclusion: %w[maintenance_task]
  validates :status, inclusion: %w[failed success]
end
