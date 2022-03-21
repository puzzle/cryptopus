# frozen_string_literal: true

# == Schema Information
#
# Table name: file_entries
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null


class FileEntry < ApplicationRecord
  belongs_to :encryptable, primary_key: :id, foreign_key: :account_id
  validates :filename,
            uniqueness: {
              scope: :encryptable,
              message: I18n.t('flashes.file_entries.uploaded_filename_already_exists')
            }
  validates :description, length: { maximum: 300 }
  validate :uploaded_file_exist
  validate :valid_file_size
  validate :filename_is_not_blank_or_nil

  scope :list, -> {}

  attr_accessor :cleartext_file

  class << self
    def create(account, params, plaintext_team_password)
      file_entry = account.file_entries.new
      file_entry.attributes = file_entry.new_attributes(params) unless params[:file].nil?
      file_entry.encrypt(plaintext_team_password)
      file_entry.save
      file_entry
    end
  end

  def label
    filename
  end

  def decrypt(team_password)
    @cleartext_file = decrypt_attr(:file, team_password)
  end

  def encrypt(team_password)
    encrypt_file(team_password)
  end

  def new_attributes(params)
    { description: params[:description],
      filename: params[:file].original_filename,
      content_type: params[:file].content_type,
      cleartext_file: params[:file].read }
  end


  private


  def valid_file_size
    return if cleartext_file.nil?

    if cleartext_file.size > 10_000_000 # 10MB
      errors.add(:base, I18n.t('flashes.file_entries.uploaded_size_to_high'))
    end
  end

  def uploaded_file_exist
    if file.nil? && cleartext_file.blank?
      errors.add(:base, I18n.t('flashes.file_entries.uploaded_file_inexistent'))
    end
  end

  def filename_is_not_blank_or_nil
    if filename.nil? || filename.blank?
      errors.add(:base, I18n.t('flashes.file_entries.uploaded_filename_is_empty'))
    end
  end

  def decrypt_attr(attr, team_password)
    crypted_file = send(attr)
    return if crypted_file.blank?

    Crypto::Symmetric::AES256.decrypt(crypted_file, team_password)
  end

  # rubocop:disable Rails/Blank
  def encrypt_file(team_password)
    return if cleartext_file.nil? || cleartext_file.empty?

    self.file = Crypto::Symmetric::AES256.encrypt(cleartext_file, team_password)
  end
  # rubocop:enable Rails/Blank
end
