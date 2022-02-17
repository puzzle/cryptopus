# frozen_string_literal: true

class Encryptable::File < Encryptable
  attr_accessor :cleartext_file
  belongs_to :encryptable_credential, class_name: 'Encryptable::Credentials', foreign_key: :credential_id

  validate :file_size
  validate :credential_id

  def decrypt(team_password)
    decrypt_attr(:file, team_password)
  end

  def encrypt(team_password)
    return if cleartext_file.blank?

    encrypt_attr(:file, team_password)
  end

  private

  def file_size
    return if cleartext_file.nil?

    if cleartext_file.size > 10.megabytes
      errors.add(:base, I18n.t('flashes.file_entries.uploaded_size_to_high'))
    end
  end

  def credential_id
    if encryptable_credential.nil?
      errors.add(:base, 'File must have credential as parent!')
    end
  end

end
