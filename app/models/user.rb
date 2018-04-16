# encoding: utf-8

# == Schema Information

# Table name: users
#
#  id                           :integer          not null, primary key
#  public_key                   :text             not null
#  private_key                  :binary           not null
#  password                     :binary
#  ldap_uid                     :integer
#  last_login_at                :datetime
#  username                     :string
#  givenname                    :string
#  surname                      :string
#  auth                         :string           default("db"), not null
#  preferred_locale             :string           default("en"), not null
#  locked                       :boolean          default(FALSE)
#  last_failed_login_attempt_at :datetime
#  failed_login_attempts        :integer          default(0), not null
#  last_login_from              :string
#  type                         :string
#  human_user_id                :integer
#  options                      :text
#  role                         :integer          default("user"), not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class User < ApplicationRecord
  validates_uniqueness_of :username
  validates :username, presence: true

  enum role: %i[user conf_admin admin]

  def update_password(old, new)
    return if ldap?
    if authenticate_db(old)
      self.password = CryptUtils.one_way_crypt(new)
      pk = CryptUtils.decrypt_private_key(private_key, old)
      self.private_key = CryptUtils.encrypt_private_key(pk, new)
      save
    end
  end

  def create_keypair(password)
    keypair = CryptUtils.new_keypair
    uncrypted_private_key = CryptUtils.extract_private_key(keypair)
    self.public_key = CryptUtils.extract_public_key(keypair)
    self.private_key = CryptUtils.encrypt_private_key(uncrypted_private_key, password)
  end

  def authenticate_db(cleartext_password)
    raise Exceptions::AuthenticationFailed unless cleartext_password.present?
    salt = password.split('$')[1]
    password.split('$')[2] == Digest::SHA512.hexdigest(salt + cleartext_password)
  end

  def label
    givenname.blank? ? username : "#{givenname} #{surname}"
  end
end
