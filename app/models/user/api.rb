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

  after_initialize :init_username, if: :human_user, unless: :persisted?
  before_create :init_token

  delegate :valid_until,
           to: :options

  def locked?
    super || human_user.locked?
  end

  def expired?
    return true unless valid_until
    valid_until < Time.now
  end

  def renew_token(human_private_key)
    self.locked = false
    old_token = decrypt_token(human_private_key)
    new_token = SecureRandom.hex(16)

    calculate_valid_until
    update_password(old_token, new_token)
    encrypt_token(new_token)
    save!
    new_token
  end

  def authenticate(cleartext_password)
    return false if locked?
    authenticate_db(cleartext_password)
  end

  def valid_for
    options.valid_for || 1.minute.seconds
  end

  def ldap?
    false
  end

  def decrypt_private_key(token)
    CryptUtils.decrypt_private_key(private_key, token)
  rescue
    raise Exceptions::DecryptFailed
  end

  private

  def decrypt_token(human_private_key)
    CryptUtils.decrypt_rsa(encrypted_token, human_private_key)
  end

  delegate :description,
           :description=,
           :encrypted_token,
           :encrypted_token=,
           :valid_for=,
           :valid_until=,
           to: :options

  def init_token
    self.options = Options.new
    token = random_token
    encrypt_token(token)
  end

  def init_username
    hash = SecureRandom.hex(3)
    self.username = "#{human_user.username}-#{hash}"
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

  def calculate_valid_until
    options.valid_until = DateTime.now.advance(seconds: valid_for)
  end
end
