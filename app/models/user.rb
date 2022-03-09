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
#

class User < ApplicationRecord
  delegate :l, to: I18n

  validates :username, uniqueness: :username
  validates :username, presence: true

  def update_password(old, new)
    return unless auth_db?

    if old.blank? || new.blank?
      raise 'passwords cannot be blank'
    end

    if authenticate_db(old)
      self.password = Crypto::Hashing.generate_salted(new)
      pk = Crypto::Symmetric::AES256.decrypt_with_salt(private_key, old)
      self.private_key = Crypto::Symmetric::AES256.encrypt_with_salt(pk, new)
      save!
    end
  end

  def create_keypair(password)
    keypair = Crypto::RSA.generate_new_keypair
    uncrypted_private_key = keypair.to_s
    self.public_key = keypair.public_key.to_s
    self.private_key = Crypto::Symmetric::AES256.encrypt_with_salt(uncrypted_private_key, password)
  end

  def authenticate_db(cleartext_password)
    authenticated = false

    if user_is_allowed? && cleartext_password.present? && auth_db?
      authenticated = Crypto::Hashing.matches?(password, cleartext_password)
    end

    authenticated
  end

  def label
    givenname.blank? ? username : "#{givenname} #{surname}"
  end

  def formatted_last_login_at
    l(last_login_at, format: :long) if last_login_at
  end

  def unlock!
    update!(locked: false, failed_login_attempts: 0)
  end

  def lock!
    update!(locked: true)
  end

  def encryptables
    Encryptable.joins(:folder).
      joins('INNER JOIN teammembers ON folders.team_id = teammembers.team_id').
      where(teammembers: { user_id: id })
  end

  def human?
    is_a?(User::Human)
  end

  private

  def user_is_allowed?
    AuthConfig.db_enabled? || !AuthConfig.db_enabled? && (username == 'root' || is_a?(User::Api))
  end
end
