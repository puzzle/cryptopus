# encoding: utf-8

# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Item < ApplicationRecord
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
      item.attributes = item.new_attributes(params) unless params[:file].nil?
      item.encrypt(plaintext_team_password)
      item.save
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
      errors[:base] << I18n.t('flashes.items.uploaded_size_to_high')
    end
  end

  def uploaded_file_exist
    if cleartext_file.nil? && file.nil?
      errors[:base] << I18n.t('flashes.items.uploaded_file_inexistent')
    end
  end

  def filename_is_not_blank_or_nil
    if filename.nil? || filename.blank?
      errors[:base] << I18n.t('flashes.items.uploaded_filename_is_empty')
    end
  end

  def decrypt_attr(attr, team_password)
    crypted_file = send(attr)
    return if crypted_file.blank?
    CryptUtils.decrypt_blob(crypted_file, team_password)
  end

  def encrypt_file(team_password)
    return if cleartext_file.blank?
    crypted_file = CryptUtils.encrypt_blob(cleartext_file, team_password)
    self.file = crypted_file
  end

end
