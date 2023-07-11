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

  class_attribute :used_encrypted_attrs

  attr_readonly :type
  validates :type, presence: true

  belongs_to :folder
  belongs_to :sender, class_name: 'User::Human'

  validates :name, presence: true
  validates :description, length: { maximum: 4000 }

  def encrypt(team_password, encryption_algorithm = nil)
    return if file? && cleartext_file.empty?

    used_encrypted_attrs.each do |attribute|
      encrypt_attr(attribute, team_password, encryption_algorithm)
    end
  end

  def decrypt(team_password)
    used_encrypted_attrs.each do |attribute|
      decrypt_attr(attribute, team_password)
    end
  end

  def recrypt(team_password, new_team_password, new_encryption_class)
    decrypt(team_password)

    @new_encryption_class = new_encryption_class
    encrypt(new_team_password)
    save!
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

  def decrypt_transferred(private_key)
    decrypt(plaintext_transfer_password(private_key))
  end

  def plaintext_transfer_password(private_key)
    Crypto::Rsa.decrypt(Base64.decode64(encrypted_transfer_password), private_key)
  end

  def used_encrypted_data_attrs
    encrypted_data.used_attributes
  end

  private

  def encrypt_attr(attr, team_password, encryption_algorithm = nil)
    cleartext_value = send(:"cleartext_#{attr}")

    encrypted_value =
      encrypt_with_encryption_class(cleartext_value, team_password, encryption_algorithm)

    return if transferred? && encrypted_value.blank?

    attr_label = cleartext_custom_attr_label if attr == :custom_attr
    encrypted_data.[]=(attr, **{
                         label: attr_label,
                         data: encrypted_value[:data],
                         iv: encrypted_value[:iv]
                       })
  end

  def decrypt_attr(attr, team_password)
    encrypted_value = encrypted_value_hash(attr)

    cleartext_value = if encrypted_value[:data].present?
                        encryption_class.decrypt(encrypted_value, team_password)
                      end

    if attr == :custom_attr
      @cleartext_custom_attr_label = encrypted_data[attr].try(:[], :label)
    end

    instance_variable_set("@cleartext_#{attr}", cleartext_value)
  end

  def encrypted_value_hash(attr)
    data_attr = encrypted_data[attr]

    data = data_attr.try(:[], :data)
    iv = data_attr.try(:[], :iv)
    { data: data, iv: iv }
  end

  def encrypt_with_encryption_class(cleartext_value, team_password, encryption_algorithm)
    if cleartext_value.presence
      @new_encryption_class = encryption_algorithm unless encryption_algorithm.nil?
      encryption_class.encrypt(cleartext_value, team_password)
    else
      { data: nil, iv: nil }
    end
  end

  def encryption_class
    @new_encryption_class || team.encryption_class
  end

  def assert_human_receiver?
    unless User.find(receiver_id).is_a?(User::Human)
      errors.add(:receiver_id, 'Must be a human user')
    end
  end

  def file?
    is_a?(Encryptable::File)
  end
end
