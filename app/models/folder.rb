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

class Folder < ApplicationRecord
  belongs_to :team
  has_many :encryptables, -> { order :name }, dependent: :destroy

  attr_readonly :team_id

  validates :name, presence: true
  validates :name, uniqueness: { scope: :team }
  validates :name, length: { maximum: 70 }
  validates :description, length: { maximum: 300 }


  def label
    name
  end
end
