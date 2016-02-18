# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Team < ActiveRecord::Base
  has_many :groups, -> { order :name }, dependent: :destroy
  has_many :teammembers, dependent: :delete_all
  has_many :members, through: :teammembers, source: :user

  # TODO: add validations
  validates :name, presence: true

  class << self
    def create(creator, params)
      raise 'root cannot create private team' if creator.root? && params[:noroot]
      team = super(params)
      return team unless team.valid?
      plaintext_team_password = CryptUtils.new_team_password
      team.add_user(creator, plaintext_team_password)
      unless team.private?
        User.admins.each do |a|
          team.add_user(a, plaintext_team_password) unless a == creator
        end
      end
      unless team.noroot? || creator.root?
        team.add_user(User.root, plaintext_team_password)
      end
      team
    end
  end

  def update_attributes(attributes)
    attributes.delete('private')
    attributes.delete('noroot')
    super(attributes)
  end

  def label
    name
  end

  def member_candidates
    excluded_user_ids = User.joins('LEFT JOIN teammembers ON users.id = teammembers.user_id').
                        where('users.uid = 0 OR users.admin = ? OR teammembers.team_id = ?', true, id).
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
    teammembers.where(user_id: user_id).first
  end

  def add_user(user, plaintext_team_password)
    raise 'user is already team member' if teammember?(user.id)
    create_teammember(user, plaintext_team_password)
  end

  def remove_user(user)
    raise 'root cannot be removed from team' if user.root?
    teammember(user.id).destroy!
  end

  def decrypt_team_password(user, plaintext_private_key)
    crypted_team_password = teammember(user.id).password
    CryptUtils.
      decrypt_team_password(crypted_team_password, plaintext_private_key)
  end

  private

  def create_teammember(user, plaintext_team_password)
    crypted_team_password = CryptUtils.
                            encrypt_team_password(plaintext_team_password, user.public_key)

    teammembers.create!(password: crypted_team_password,
                        user: user)
  end

end
