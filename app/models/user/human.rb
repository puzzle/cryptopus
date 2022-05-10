# frozen_string_literal: true

# == Schema Information
#
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
#  role                         :integer          default("user"), not null


class User::Human < User
  require 'ipaddr'

  validates :username, length: { maximum: 20 }
  validate :must_be_valid_ip

  has_many :teammembers, dependent: :destroy, foreign_key: :user_id
  has_many :teams, -> { order :name }, through: :teammembers
  has_many :user_favourite_teams, dependent: :destroy, foreign_key: :user_id
  has_many :favourite_teams, -> { order :name }, through: :user_favourite_teams, source: :team
  has_many :api_users, class_name: 'User::Api', dependent: :destroy,
                       foreign_key: :human_user_id

  has_one :personal_team, class_name: 'Team', dependent: :destroy, foreign_key: :personal_owner_id

  scope :locked, -> { where(locked: true) }
  scope :unlocked, -> { where(locked: false) }
  scope :admins, (-> { where(role: :admin) })
  scope :ldap, -> { where(auth: 'ldap') }

  default_scope { order('username') }

  has_one :default_ccli_user, foreign_key: :default_ccli_user_id, class_name: 'User::Api',
                              primary_key: :id, dependent: :destroy

  before_destroy :protect_if_last_teammember
  after_create :create_personal_team!

  delegate :l, to: I18n

  enum role: [:user, :conf_admin, :admin]

  class << self
    def create_db_user(password, user_params)
      user = new(user_params)
      user.auth = 'db'
      user.create_keypair password
      user.password = Crypto::Hashing.generate_salted(password)
      user
    end

    def create_root(password)
      user = new(provider_uid: '0',
                 username: 'root',
                 givenname: 'root',
                 surname: '',
                 auth: 'db',
                 role: :admin,
                 password: Crypto::Hashing.generate_salted(password))
      user.create_keypair(password)
      user.save!
    end

    def root
      find_by(username: 'root')
    end
  end

  # Instance Methods

  def only_teammember_in_any_team?
    only_teammember_teams.any?
  end

  def only_teammember_teams
    Team.where(id: Teammember.group('team_id').
           having('count(*) = 1').
           select('team_id')).
      joins(:members).where('users.id = ?', id)
  end

  def update_role(actor, role, private_key)
    was_admin = admin?
    update!(role: role)

    if admin?
      empower(actor, private_key)
    elsif was_admin
      disempower
    end
  end

  def recrypt_private_key!(new_password, old_password)
    preform_private_key_recryption!(new_password, old_password) && save!
  end

  def root?
    username == 'root'
  end

  def auth_db?
    auth == 'db'
  end

  def ldap?
    auth == 'ldap'
  end

  def oidc?
    auth == 'oidc'
  end

  def unauthorized
    errors.add(:base, I18n.t('activerecord.errors.models.user.new_password_invalid'))
    false
  end

  def decrypt_private_key(password)
    Crypto::Symmetric::Aes256.decrypt_with_salt(private_key, password)
  rescue StandardError
    raise Exceptions::DecryptFailed
  end

  def folders
    Folder.joins('INNER JOIN teammembers ON folders.team_id = teammembers.team_id').
      where(teammembers: { user_id: id })
  end

  def create_personal_team!
    team = Team::Personal.create(self)
    team.folders.create!(name: 'default')
    save!
  end

  private

  def preform_private_key_recryption!(new_password, old_password)
    plaintext_private_key = Crypto::Symmetric::Aes256.decrypt_with_salt(private_key, old_password)
    Crypto::Rsa.validate_keypair(plaintext_private_key, public_key)
    self.private_key = Crypto::Symmetric::Aes256.encrypt_with_salt(
      plaintext_private_key,
      new_password
    )
    true
  rescue Exceptions::DecryptFailed
    errors.add(:base, I18n.t('activerecord.errors.models.user.old_password_invalid'))
    false
  end

  def empower(actor, private_key)
    teams = Team.where(teams: { private: false })

    teams.each do |t|
      next if t.teammember?(self)

      active_teammember = t.teammembers.find_by user_id: actor.id
      team_password = Crypto::Rsa.decrypt(active_teammember.password, private_key)
      t.add_user(self, team_password)
    end
  end

  def disempower
    raise 'root can not be disempowered' if username == 'root'

    teammembers.joins(:team).where(teams: { private: false }).destroy_all
  end

  def protect_if_last_teammember
    !only_teammember_in_any_team?
  end

  def must_be_valid_ip
    if last_login_from?
      begin
        IPAddr.new(last_login_from.to_s)
      rescue IPAddr::InvalidAddressError
        errors.add(last_login_from, "invalid ip address: #{last_login_from}")
      end
    end
  end
end
