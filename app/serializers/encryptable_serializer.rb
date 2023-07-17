# frozen_string_literal: true

# == Schema Information
#
# Table name: encryptables
#
#  id          :integer          not null, primary key
#  name        :string(70)       default(""), not null
#  folder_id   :integer          default(0), not null
#  description :text
#  username    :binary
#  password    :binary
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class EncryptableSerializer < ApplicationSerializer
  attributes :id, :name, :description, :sender_name

  belongs_to :folder

  def sender_name
    object.sender&.label
  end
end
