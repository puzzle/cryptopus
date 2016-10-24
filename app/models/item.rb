# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Item < ActiveRecord::Base
  belongs_to :account
  validates :filename, uniqueness: { scope: :account }
  validates :filename, presence: true
  validates :description, length: { maximum: 300}

  attr_accessor :cleartext_file

  def label
    filename
  end

  def decrypt(team_password)
    @cleartext_file = decrypt_attr(:file, team_password)
  end

  def encrypt(team_password)
    encrypt_file(team_password)
  end

  def encrypt_new_item(file, team_password)
    @cleartext_file = file
    encrypt_file(team_password)
  end

  private

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
