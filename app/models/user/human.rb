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

class User::Human < User
  include User::Human::Ldap
  include User::Human::Authentication

  validates :username, length: { maximum: 20 }
  validate :must_be_valid_ip

  has_many :teammembers, dependent: :destroy, foreign_key: :user_id
  has_many :recryptrequests, dependent: :destroy, foreign_key: :user_id
  has_many :teams, -> { order :name }, through: :teammembers
  has_many :api_tokens, dependent: :destroy, foreign_key: :human_user_id

  scope :locked, (-> { where(locked: true) })
  scope :unlocked, (-> { where(locked: false) })

  scope :admins, (-> { where(admin: true) })

  default_scope { order('username') }

  before_destroy :protect_if_last_teammember

  class << self

    def create_db_user(password, user_params)
      user = new(user_params)
      user.auth = 'db'
      user.create_keypair password
      user.password = CryptUtils.one_way_crypt(password)
      user
    end

    def create_root(password)
      user = new(uid: 0,
                 username: 'root',
                 givenname: 'root',
                 surname: '',
                 auth: 'db',
                 admin: true,
                 password: CryptUtils.one_way_crypt(password))
      user.create_keypair(password)
      user.save!
    end

    def root
      find_by(uid: 0)
    end
  end

  # Instance Methods

  def last_teammember_in_any_team?
    last_teammember_teams.any?
  end

  def last_teammember_teams
    Team.where(id: Teammember.group('team_id').
           having('count(*) = 1').
           select('team_id')).
      joins(:members).where('users.id = ?', id)
  end

  # Updates Information about the user
  def update_info
    update_info_from_ldap if ldap?
    update_attribute(:last_login_at, Time.zone.now)
  end

  def update_last_login_ip(last_login_ip)
    update_attribute(:last_login_from, last_login_ip)
  end

  def toggle_admin(actor, private_key)
    if self == actor || !actor.admin?
      raise 'user is not allowed to empower/disempower this user'
    end

    update(admin: !admin?)
    admin? ? empower(actor, private_key) : disempower
  end

  # rubocop:disable MethodLength
  def recrypt_private_key!(new_password, old_password)
    unless authenticate(new_password)
      errors.add(:base,
                 I18n.t('activerecord.errors.models.user.new_password_invalid'))
      return false
    end

    begin
      plaintext_private_key = CryptUtils.decrypt_private_key(private_key, old_password)
      CryptUtils.validate_keypair(plaintext_private_key, public_key)
      self.private_key = CryptUtils.encrypt_private_key(plaintext_private_key, new_password)
    rescue Exceptions::DecryptFailed
      errors.add(:base, I18n.t('activerecord.errors.models.user.old_password_invalid'))
      return false
    end
    save!
  end

  def label
    givenname.blank? ? username : "#{givenname} #{surname}"
  end

  def root?
    uid.zero?
  end

  def auth_db?
    auth == 'db'
  end

  def update_password(old, new)
    return if ldap?
    if authenticate_db(old)
      self.password = CryptUtils.one_way_crypt(new)
      pk = CryptUtils.decrypt_private_key(private_key, old)
      self.private_key = CryptUtils.encrypt_private_key(pk, new)
      save
    end
  end

  def migrate_legacy_private_key(password)
    decrypted_legacy_private_key = CryptUtilsLegacy.decrypt_private_key(private_key, password)
    newly_encrypted_private_key = CryptUtils.encrypt_private_key(decrypted_legacy_private_key,
                                                                 password)
    update_attribute(:private_key, newly_encrypted_private_key)
  end

  def decrypt_private_key(password)
    migrate_legacy_private_key(password) if legacy_private_key?
    CryptUtils.decrypt_private_key(private_key, password)
  rescue
    raise Exceptions::DecryptFailed
  end

  def accounts
    Account.joins(:group).
      joins('INNER JOIN teammembers ON groups.team_id = teammembers.team_id').
      where(teammembers: { user_id: id })
  end

  def legacy_password?
    return false if ldap?
    password.match('sha512').nil?
  end

  def groups
    Group.joins('INNER JOIN teammembers ON groups.team_id = teammembers.team_id').
      where(teammembers: { user_id: id })
  end

  def search_teams(term)
    teams.where('name like ?', "%#{term}%")
  end

  def search_groups(term)
    groups.where('name like ?', "%#{term}%")
  end

  def search_accounts(query)
    query.split(' ').inject(accounts.includes(group: [:team])) do |relation, term|
      relation.where('accountname like ? or accounts.description like ?', "%#{term}%", "%#{term}%")
    end
  end

  def legacy_private_key?
    /^Salted/ !~ private_key
  end

  def unlock
    update!(locked: false, failed_login_attempts: 0)
  end

  private

  def empower(actor, private_key)
    teams = Team.where(teams: { private: false })

    teams.each do |t|
      next if t.teammember?(self)
      active_teammember = t.teammembers.find_by user_id: actor.id
      team_password = CryptUtils.decrypt_team_password(active_teammember.password, private_key)
      t.add_user(self, team_password)
    end
  end

  def disempower
    raise 'root can not be disempowered' if username == 'root'
    teammembers.joins(:team).where(teams: { private: false }).destroy_all
  end

  def protect_if_last_teammember
    !last_teammember_in_any_team?
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
