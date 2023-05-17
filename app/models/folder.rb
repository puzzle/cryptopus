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
  validate :only_one_personal_inbox

  def label
    name
  end

  def only_one_personal_inbox
    if personal_inbox && team.folders.where(personal_inbox: true).where.not(id: id).exists?
      errors.add(:personal_inbox, I18n.t('flashes.folders.duplicated_inbox'))
    end
  end

  def unread_count_transferred_files
    encryptables.all.where.not(encrypted_transfer_password: nil).count
  end
end
