# frozen_string_literal: true

# == Schema Information
#
# Table name: file_entries
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class FileEntrySerializer < ApplicationSerializer

  attributes :id, :filename, :description

  belongs_to :account

end
