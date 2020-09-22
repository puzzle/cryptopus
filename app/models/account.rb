# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  accountname :string(70)       default(""), not null
#  folder_id    :integer          default(0), not null
#  description :text
#  username    :binary
#  password    :binary
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tag         :string
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Account < ApplicationRecord

  attr_readonly :type
  validates :type, presence: true

  belongs_to :folder
  has_many :file_entries, dependent: :destroy

  validates :accountname, presence: true
  validates :accountname, uniqueness: { scope: :folder }
  validates :accountname, length: { maximum: 70 }
  validates :description, length: { maximum: 4000 }

  serialize :encrypted_data, EncryptedData

  def self.policy_class
    AccountPolicy
  end

  def label
    accountname
  end
end
