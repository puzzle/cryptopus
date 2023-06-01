# frozen_string_literal: true

class Encryptable::Credentials < Encryptable
  attr_accessor :cleartext_password, :cleartext_username, :cleartext_token, :cleartext_pin,
                :cleartext_email, :cleartext_custom_attr_label, :cleartext_custom_attr

  has_many :encryptable_files,
           class_name: 'Encryptable::File',
           foreign_key: :credential_id,
           dependent: :destroy

  validates :name, length: { maximum: 70 }
  validates :name, uniqueness: { scope: :folder }
  validates :folder_id, presence: true
  # validates :cleartext_custom_attr, presence: { if: :cleartext_custom_attr_label }
  # validates :cleartext_custom_attr_label, presence: { if: :cleartext_custom_attr }

  def decrypt(team_password)
    decrypt_attr(:username, team_password)
    decrypt_attr(:password, team_password)
    decrypt_attr(:token, team_password)
    decrypt_attr(:pin, team_password)
    decrypt_attr(:email, team_password)
    decrypt_attr(:custom_attr, team_password)
  end

  def encrypt(team_password)
    encrypt_attr(:username, team_password)
    encrypt_attr(:password, team_password)
    encrypt_attr(:token, team_password)
    encrypt_attr(:pin, team_password)
    encrypt_attr(:email, team_password)
    encrypt_attr(:custom_attr, team_password)
  end

end
