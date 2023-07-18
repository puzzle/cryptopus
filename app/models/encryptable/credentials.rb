# frozen_string_literal: true

class Encryptable::Credentials < Encryptable
  attr_accessor :cleartext_password, :cleartext_username, :cleartext_token, :cleartext_pin,
                :cleartext_email, :cleartext_custom_attr_label, :cleartext_custom_attr

  self.used_encrypted_attrs = [:username, :password, :token, :pin, :email, :custom_attr].freeze

  has_many :encryptable_files,
           class_name: 'Encryptable::File',
           foreign_key: :credential_id,
           dependent: :destroy

  validates :name, length: { maximum: 70 }
  validates :name, uniqueness: { scope: :folder }
  validates :folder_id, presence: true
end
