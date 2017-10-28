# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                           :integer          not null, primary key
#  public_key                   :text             not null
#  private_key                  :binary           not null
#  password                     :binary
#  admin                        :boolean          default(FALSE), not null
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
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class User::ApiToken < User

  VALID_FOR_OPTIONS = { one_min: 1.minute.seconds,
                        five_mins: 5.minutes.seconds,
                        twelve_hours: 12.hours.seconds,
                        infinite: 0
                      }.freeze
                         

  belongs_to :human_user, class_name: 'User::Human'

  serialize :options, User::ApiToken::Options

  validates :human_user, presence: true
  validates :valid_for, inclusion: VALID_FOR_OPTIONS.values

  after_initialize :init_username, if: :human_user
  before_create :init_token

  def renew_token(human_private_key)
    # create new random token
    # recrypt private key with new password
    #new_token = SecureRandom.hex(16)
  end

  def authenticate(cleartext_password)
    return false if locked?
    authenticate_db(cleartext_password)
  end

  def valid_for
    options.valid_for || 1.minute.seconds
  end

  private

  delegate :description, :description=, :encrypted_token, :encrypted_token=,
    :valid_for=, to: :options

  def init_token
    self.options = Options.new
    token = random_token
    encrypt_token(token)
  end

  def init_username
    self.username = "#{human_user.username}-#{SecureRandom.hex(3)}"
  end

  def random_token
    SecureRandom.hex(16)
  end

  def encrypt_token(token)
    public_key = human_user.public_key
    self.encrypted_token = CryptUtils.encrypt_rsa(token, public_key)
    create_keypair(token)
    self.password = CryptUtils.one_way_crypt(token)
  end

  def decrypt_token(human_private_key)
    CryptUtils.decrypt_rsa(encrypted_token, human_private_key)
  end

end
