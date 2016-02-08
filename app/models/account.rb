# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Account < ActiveRecord::Base

  belongs_to :group
  has_many :items, dependent: :destroy

  attr_accessor :cleartext_password, :cleartext_username

  def as_json(options = {})
    h = super(options)
    h[:group] = group.name
    h[:team] = group.team.name
    h[:team_id] = group.team.id
    h[:cleartext_password] = cleartext_password
    h[:cleartext_username] = cleartext_username
    h.delete('description')
    h.delete('created_at')
    h.delete('updated_at')
    h.delete('username')
    h.delete('password')
    h
  end

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
    return unless crypted_value.present?
    CryptUtils.decrypt_blob(crypted_value, team_password)
  end

  def encrypt_username(team_password)
    return unless cleartext_username.present?
    crypted_value = CryptUtils.encrypt_blob(cleartext_username, team_password)
    self.username = crypted_value
  end

  def encrypt_password(team_password)
    return unless cleartext_password.present?
    crypted_value = CryptUtils.encrypt_blob(cleartext_password, team_password)
    self.password = crypted_value
  end

end
