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
#  personal_inbox :boolean       default(false)
#

class Folder < ApplicationRecord
  belongs_to :team
  has_many :encryptables, dependent: :destroy

  attr_readonly :team_id

  validates :name, presence: true
  validates :name, uniqueness: { scope: :team }
  validates :name, length: { maximum: 70 }
  validates :description, length: { maximum: 300 }
  validates :personal_inbox, uniqueness: { scope: :team, if: :personal_inbox? }

  def label
    name
  end

  def unread_count_transferred_encryptables
    encryptables.where.not(encrypted_transfer_password: nil).count
  end
end
