# frozen_string_literal: true

# == Schema Information
#
# Table name: folders
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team_id     :integer          default(0), not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class FolderSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :unread_transferred_files

  has_many :encryptables, serializer: EncryptableMinimalSerializer do
    if object.personal_inbox?
      object.encryptables.order('created_at DESC')
    else
      object.encryptables.order(:name)
    end
  end

  def unread_transferred_files
    # rubocop:disable Metrics/LineLength
    object.personal_inbox? ? object.encryptables.all.where.not(encrypted_transfer_password: nil).count : nil
    # rubocop:enable Metrics/LineLength
  end

end
