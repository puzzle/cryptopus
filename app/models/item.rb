# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Item < ActiveRecord::Base
  belongs_to :account
  validates :filename, uniqueness: { scope: :account }
  validates :description, length: { maximum: 300 }
  validate :uploaded_file_exist
  validate :valid_file_size
  validate :filename_is_not_blank_or_nil

  attr_accessor :cleartext_file

  class << self
    def create(account, params, plaintext_team_password)
      item = account.items.new
      return item if params[:file].nil?
      item.description = params[:description]
      item.filename = params[:file].original_filename
      item.content_type = params[:file].content_type
      item.cleartext_file = params[:file].read
      if item.valid?
        item.encrypt(plaintext_team_password)
        item.save!
      end
      item
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


  private

  def valid_file_size
    return if self.cleartext_file.nil?
    if self.cleartext_file.size > 10_000_000 # 10MB
      errors[:base] << I18n.t('flashes.items.uploaded_size_to_high')
    end
  end

  def uploaded_file_exist
    if self.cleartext_file.nil? && self.file.nil?
      errors[:base] << I18n.t('flashes.items.uploaded_file_inexistent')
    end
  end

  def filename_is_not_blank_or_nil
    if self.filename.nil? || self.filename.blank?
      errors[:base] << I18n.t('flashes.items.uploaded_filename_is_empty')
    end
  end

  def decrypt_attr(attr, team_password)
    crypted_file = send(attr)
    return unless crypted_file.present?
    CryptUtils.decrypt_blob(crypted_file, team_password)
  end

  def encrypt_file(team_password)
    return unless cleartext_file.present?
    crypted_file = CryptUtils.encrypt_blob(cleartext_file, team_password)
    self.file = crypted_file
  end

end
