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
#

class Encryptable < ApplicationRecord
  serialize :encrypted_data, ::EncryptedData

  attr_readonly :type
  validates :type, presence: true

  belongs_to :folder
  belongs_to :sender, class_name: 'User::Human'

  validates :name, presence: true
  validates :description, length: { maximum: 4000 }

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

  def recrypt_transferred(receiver_private_key, team_password)
    decrypt(plaintext_transfer_password(receiver_private_key))
    self.encrypted_transfer_password = nil
    encrypt(team_password)
    save!
  end

  def transferred?
    encrypted_transfer_password.present? && sender_id.present?
  end

  def inbox_folder_present?
    Folder.find(folder_id)&.name == 'inbox' if folder_id
  end

  def plaintext_transfer_password(private_key)
    Crypto::Rsa.decrypt(Base64.decode64(encrypted_transfer_password), private_key)
  end

  private

  def encrypt_attr(attr, team_password)
    cleartext_value = send(:"cleartext_#{attr}")

    # Rubocop suggests correctable from .nil? || .empty? to .blank?
    # Rubocop is here disabled, because .blank? is not working on UTF-8 String which are not ASCII
    # Rubocop correctable must be disabled with all
    # rubocop:disable all
    encrypted_value = if cleartext_value.nil? || cleartext_value.empty?
                        nil
                      else
                        Crypto::Symmetric::Aes256.encrypt(cleartext_value, team_password)
                      end
    # rubocop:enable all
    build_encrypted_data(attr, encrypted_value)
  end

  def build_encrypted_data(attr, encrypted_value)
    attr_label = send(:cleartext_custom_attr_label) if attr == :custom_attr
    encrypted_data.[]=(
      attr, **{ label: attr_label, data: encrypted_value, iv: nil }
    )
  end

  def decrypt_attr(attr, team_password)
    encrypted_value = encrypted_data[attr].try(:[], :data)

    cleartext_value = if encrypted_value
                        Crypto::Symmetric::Aes256.decrypt(encrypted_value, team_password)
                      end

    if attr == :custom_attr
      @cleartext_custom_attr_label = encrypted_data[:custom_attr][:label]
    end

    instance_variable_set("@cleartext_#{attr}", cleartext_value)
  end

  def assert_human_receiver?
    unless User.find(receiver_id).is_a?(User::Human)
      errors.add(:receiver_id, 'Must be a human user')
    end
  end
end
