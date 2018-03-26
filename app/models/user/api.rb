# encoding: utf-8

# == Schema Information
#
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
#  role                         :integer          default(0), not null
#

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class User::Api < User

  VALID_FOR_OPTIONS = { one_min: 1.minute.seconds,
                        five_mins: 5.minutes.seconds,
                        twelve_hours: 12.hours.seconds,
                        infinite: 0 }.freeze

  belongs_to :human_user, class_name: 'User::Human'

  serialize :options, User::Api::Options

  validates :human_user, :valid_for, presence: true
  validates :valid_for, inclusion: VALID_FOR_OPTIONS.values

  after_initialize :init_username, if: :human_user
  before_create :init_token

  def self.create_api_user(password, user_params)
    api = new(user_params)
    api.create_keypair password
    api.password = CryptUtils.one_way_crypt(password)
    api
  end

  def locked?
    locked || human_user.locked?
  end

  def renew_token(human_private_key)
    old_token = decrypt_token(human_private_key)
    new_token = SecureRandom.hex(16)
    update_password(old_token, new_token)
    options.valid_until = valid_until_time
  end

  def authenticate(cleartext_password)
    return false if locked?
    authenticate_db(cleartext_password)
  end

  def valid_for
    options.valid_for || 1.minute.seconds
  end

  def valid_until
    options.valid_until
  end

  def ldap?
    false
  end

  private

  delegate :description,
           :description=,
           :encrypted_token,
           :encrypted_token=,
           :valid_for=,
           to: :options

  def valid_until_time
    Time.now.advance(seconds: options.valid_for)
  end

  def init_token
    self.options = Options.new
    token = random_token
    encrypt_token(token)
  end

  def init_username
    hash = SecureRandom.hex(3)
    self.username = username.present? ? "#{username}-#{hash}" : "#{human_user.username}-#{hash}"
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
