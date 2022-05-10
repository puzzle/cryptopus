# frozen_string_literal: true

class Encryptable::File < Encryptable
  attr_accessor :cleartext_file, :cleartext_content_type

  belongs_to :encryptable_credential,
             class_name: 'Encryptable::Credentials',
             foreign_key: :credential_id

  validate :file_size
  validates :credential_id, presence: true
  validates :name, uniqueness: { scope: :credential_id }
  validates :cleartext_file, presence: true

  def decrypt(team_password)
    decrypt_attr(:file, team_password)
    decrypt_attr(:content_type, team_password)
  end

  def encrypt(team_password)
    return if cleartext_file.blank?

    encrypt_attr(:file, team_password)
    encrypt_attr(:content_type, team_password)
  end

  private

  def file_size
    return if cleartext_file.nil?

    if cleartext_file.size > 10.megabytes
      errors.add(:base, I18n.t('flashes.file_entries.uploaded_size_to_high'))
    end
  end

end