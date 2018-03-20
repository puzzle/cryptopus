# encoding: utf-8
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

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Team < ApplicationRecord
  has_many :groups, -> { order :name }, dependent: :destroy
  has_many :teammembers, dependent: :delete_all
  has_many :members, through: :teammembers, source: :user

  validates :name, presence: true
  validates :name, length: { maximum: 40 }
  validates :description, length: { maximum: 300 }

  class << self
    def create(creator, params)
      team = super(params)
      return team unless team.valid?
      plaintext_team_password = CryptUtils.new_team_password
      team.add_user(creator, plaintext_team_password)
      unless team.private?
        User::Human.admins.each do |a|
          team.add_user(a, plaintext_team_password) unless a == creator
        end
      end
      team
    end
  end

  def update_attributes(attributes)
    attributes.delete('private')
    super(attributes)
  end

  def label
    name
  end

  def member_candidates
    excluded_user_ids = User.
                        unscoped.joins('LEFT JOIN teammembers ON users.id = teammembers.user_id').
                        where('users.username = "root" OR teammembers.team_id = ?', id).
                        distinct.
                        pluck(:id)
    User.where('id NOT IN(?)', excluded_user_ids)
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
    CryptUtils.decrypt_rsa(crypted_team_password, plaintext_private_key)
  end

  private

  def create_teammember(user, plaintext_team_password)
    crypted_team_password = CryptUtils.
                            encrypt_rsa(plaintext_team_password, user.public_key)

    teammembers.create!(password: crypted_team_password,
                        user: user)
  end

end
