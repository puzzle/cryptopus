# frozen_string_literal: true

# == Schema Information

# Table name: users
#
#  id                           :integer          not null, primary key
#  public_key                   :text             not null
#  private_key                  :binary           not null
#  password                     :binary
#  provider_uid                 :string
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

class User::Api < User

  attr_accessor :ccli_user

  VALID_FOR_OPTIONS = { one_min: 1.minute.seconds,
                        five_mins: 5.minutes.seconds,
                        twelve_hours: 12.hours.seconds,
                        infinite: 0 }.freeze

  belongs_to :human_user, class_name: 'User::Human'

  serialize :options, User::Api::Options

  validates :human_user, :valid_for, presence: true
  validates :valid_for, inclusion: VALID_FOR_OPTIONS.values

  has_many :teammembers, dependent: :destroy, foreign_key: :user_id
  has_many :teams, -> { order :name }, through: :teammembers

  after_initialize :init_username, if: :human_user, unless: :persisted?
  before_create :init_token

  delegate :valid_until,
           to: :options

  def locked?
    super || expired? || human_user.locked?
  end

  def expired?
    return false if valid_for.zero?
    return true unless valid_until

    valid_until < Time.zone.now
  end

  def renew_token_by_human(human_private_key)
    self.locked = false
    old_token = decrypt_token(human_private_key)
    renew_token(old_token)
  end

  def renew_token(old_token)
    new_token = SecureRandom.hex(16)

    refresh_valid_until
    update_password(old_token, new_token)
    encrypt_token(new_token)
    save!
    new_token
  end

  def valid_for
    options.valid_for || 1.minute.seconds
  end

  def auth_db?
    true
  end

  def decrypt_private_key(token)
    Crypto::Symmetric::Aes256.decrypt_with_salt(private_key, token)
  rescue StandardError
    raise Exceptions::DecryptFailed
  end

  private

  def decrypt_token(human_private_key)
    Crypto::Rsa.decrypt(encrypted_token, human_private_key)
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
    create_keypair(token)
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
    self.encrypted_token = Crypto::Rsa.encrypt(token, public_key)
    self.password = Crypto::Hashing.generate_salted(token)
  end

  def refresh_valid_until
    return if valid_for.zero?

    options.valid_until = Time.zone.now.advance(seconds: valid_for)
  end
end
