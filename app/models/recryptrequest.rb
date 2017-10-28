# encoding: utf-8

# == Schema Information
#
# Table name: recryptrequests
#
#  id      :integer          not null, primary key
#  user_id :integer          default(0), not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Recryptrequest < ApplicationRecord
  belongs_to :user, class_name: 'User::Human', foreign_key: :user_id
end
