# encoding: utf-8
# == Schema Information
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  accountname :string(70)       default(""), not null
#  group_id    :integer          default(0), not null
#  description :text
#  username    :binary
#  password    :binary
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tag         :string
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Account < ApplicationRecord

  belongs_to :group
  has_many :items, dependent: :destroy

  validates :accountname, presence: true
  validates :accountname, uniqueness: { scope: :group }
  validates :accountname, length: { maximum: 70 }
  validates :description, length: { maximum: 4000 }

  attr_accessor :cleartext_password, :cleartext_username

  def label
    accountname
  end

  def decrypt(team_password)
    @cleartext_username = decrypt_attr(:username, team_password)
    @cleartext_password = decrypt_attr(:password, team_password)
  end

  def encrypt(team_password)
    encrypt_username(team_password)
    encrypt_password(team_password)
  end

  private

  def decrypt_attr(attr, team_password)
    crypted_value = send(attr)
    return if crypted_value.blank?
    CryptUtils.decrypt_blob(crypted_value, team_password)
  end

  def encrypt_username(team_password)
    return self.username = '' if cleartext_username.blank?
    crypted_value = CryptUtils.encrypt_blob(cleartext_username, team_password)
    self.username = crypted_value
  end

  def encrypt_password(team_password)
    return if cleartext_password.blank?
    crypted_value = CryptUtils.encrypt_blob(cleartext_password, team_password)
    self.password = crypted_value
  end

end
