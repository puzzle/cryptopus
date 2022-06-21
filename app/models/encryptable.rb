# frozen_string_literal: true

# == Schema Information
#
# Table name: encryptables
#
#  id          :integer          not null, primary key
#  name         :string(70)       default(""), not null
#  folder_id    :integer          default(0), not null
#  description :text
#  username    :binary
#  password    :binary
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tag         :string
#

class Encryptable < ApplicationRecord

  serialize :encrypted_data, ::EncryptedData

  attr_readonly :type
  validates :type, presence: true

  belongs_to :folder

  validates :name, presence: true
  validates :description, length: { maximum: 4000 }

  scope :without_files, -> { where.not(type: Encryptable::File.sti_name) }

  include PgSearch::Model
  pg_search_scope :search_starts_with,
                  against: [:name, :description],
                  using: {
                    tsearch: { prefix: true }
                  }
  include PgSearch::Model
  pg_search_scope :search_starts_with,
                  against: [:name, :description],
                  using: {
                    tsearch: { prefix: true }
                  }

  def encrypt(_team_password)
    raise 'implement in subclass'
  end

  def decrypt(_team_password)
    raise 'implement in subclass'
  end

  def self.policy_class
    EncryptablePolicy
  end

  def label
    name
  end

  def team
    folder.team
  end

  private

  def encrypt_attr(attr, team_password)
    cleartext_value = send(:"cleartext_#{attr}")

    encrypted_value = if cleartext_value.blank?
                        nil
                      else
                        Crypto::Symmetric::Aes256.encrypt(cleartext_value, team_password)
                      end

    encrypted_data.[]=(attr, **{ data: encrypted_value, iv: nil })
  end

  def decrypt_attr(attr, team_password)
    encrypted_value = encrypted_data[attr].try(:[], :data)

    cleartext_value = if encrypted_value
                        Crypto::Symmetric::Aes256.decrypt(encrypted_value, team_password)
                      end

    instance_variable_set("@cleartext_#{attr}", cleartext_value)
  end

end
