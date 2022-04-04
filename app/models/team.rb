# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(40)       default(""), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  visible     :boolean          default(TRUE), not null
#  private     :boolean          default(FALSE), not null
#

class Team < ApplicationRecord
  attr_accessor :personal_team
  attr_readonly :private
  has_many :folders, -> { order :name }, dependent: :destroy
  has_many :teammembers, dependent: :delete_all
  has_many :members, through: :teammembers, source: :user
  has_one :personal_team_owner, class_name: 'User::Human', inverse_of: 'personal_team', foreign_key: :personal_team_id
  has_many :user_favourite_teams, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 40 }
  validates :description, length: { maximum: 300 }

  class << self
    def create(creator, params)
      team = super(params)
      return team unless team.valid?

      plaintext_team_password = Crypto::Symmetric::Aes256.random_key
      team.add_user(creator, plaintext_team_password)
      unless team.private?
        User::Human.admins.each do |a|
          team.add_user(a, plaintext_team_password) unless a == creator
        end
      end
      team
    end
  end

  def label
    name
  end

  def member_candidates
    excluded_user_ids = User::Human.
                        unscoped.joins('LEFT JOIN teammembers ON users.id = teammembers.user_id').
                        where('users.username = "root" OR teammembers.team_id = ?', id).
                        distinct.
                        pluck(:id)
    User::Human.where('id NOT IN(?)', excluded_user_ids)
  end

  def last_teammember?(user_id)
    teammembers.count == 1 && teammember?(user_id)
  end

  def teammember?(user_id)
    teammember(user_id).present?
  end

  def teammember(user_id)
    teammembers.find_by(user_id: user_id)
  end

  def add_user(user, plaintext_team_password)
    raise 'user is already team member' if teammember?(user.id)

    create_teammember(user, plaintext_team_password)
  end

  def remove_user(user)
    teammember(user.id).destroy!
  end

  def decrypt_team_password(user, plaintext_private_key)
    crypted_team_password = teammember(user.id).password
    Crypto::Rsa.decrypt(crypted_team_password, plaintext_private_key)
  end

  private

  def create_teammember(user, plaintext_team_password)
    encrypted_team_password = Crypto::Rsa.encrypt(plaintext_team_password, user.public_key)
    teammembers.create!(password: encrypted_team_password, user: user)
  end

end
