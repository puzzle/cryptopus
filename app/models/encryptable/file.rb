# frozen_string_literal: true

class Encryptable::File < Encryptable
  attr_accessor :cleartext_file
  belongs_to :encryptable_credentials, :class_name => 'Encryptable::Credentials', primary_key: :id

  validate :file_size

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

end
