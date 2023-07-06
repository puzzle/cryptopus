# frozen_string_literal: true

USED_ENCRYPTED_ATTRS = [:username, :password, :token, :pin, :email, :custom_attr].freeze

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

  def decrypt(team_password)
    USED_ENCRYPTED_ATTRS.each do |attribute|
      decrypt_attr(attribute, team_password)
    end
  end

  def encrypt(team_password, encryption_algorithm = nil)
    USED_ENCRYPTED_ATTRS.each do |attribute|
      encrypt_attr(attribute, team_password, encryption_algorithm)
    end
  end

end
