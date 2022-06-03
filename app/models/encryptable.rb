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

  def encrypt(_team_password)
    raise 'implement in subclass'
  end

  def decrypt(_team_password)
    raise 'implement in subclass'
  end

  def recrypt(team_password, new_team_password)
    decrypt(team_password)
    update_encryption_algorithm
    encrypt(new_team_password)
    save!
  end

  def encryption_algorithm
    self[:encryption_algorithm]
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
                        { data: nil, iv: nil }
                      else
                        encryption_class.encrypt(cleartext_value, team_password)
                      end

    encrypted_data.[]=(attr, **{ data: encrypted_value[:data], iv: encrypted_value[:iv] })
  end

  def decrypt_attr(attr, team_password)
    data_attr = encrypted_data[attr]

    data = data_attr.try(:[], :data)
    iv = data_attr.try(:[], :iv)
    encrypted_value = { data: data, iv: iv }

    cleartext_value = if data.present?
                        encryption_class.decrypt(encrypted_value, team_password)
                      end

    instance_variable_set("@cleartext_#{attr}", cleartext_value)
  end

  def encryption_class
    Crypto::Symmetric::EncryptionAlgorithm::ALGORITHMS[encryption_algorithm.to_sym]
  end

  def update_encryption_algorithm
    self.encryption_algorithm = Crypto::Symmetric::EncryptionAlgorithm.latest_algorithm
  end

end
