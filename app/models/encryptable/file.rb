# frozen_string_literal: true

class Encryptable::File < Encryptable
  attr_accessor :cleartext_file

  belongs_to :encryptable_credential,
             class_name: 'Encryptable::Credentials',
             foreign_key: :credential_id

  validates :name, uniqueness: { scope: :credential_id }, if: :credential_id

  validate :file_size, on: [:create, :update]

  def decrypt(team_password)
    decrypt_attr(:file, team_password)
  end

  def encrypt(team_password, receiver_algorithm = nil)
    return if cleartext_file.empty?

    encrypt_attr(:file, team_password, receiver_algorithm)
  end

  def team
    folder&.team || encryptable_credential.folder.team
  end

  private

  def file_size
    return if cleartext_file.nil?

    if cleartext_file.size == 0.byte
      errors.add(:base, I18n.t('flashes.encryptable_files.uploaded_file_blank'))
      return
    end

    if cleartext_file.size > 10.megabytes
      errors.add(:base, I18n.t('flashes.encryptable_files.uploaded_size_to_high'))
    end
  end

end
