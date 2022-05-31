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

class Team::Shared < Team

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

  def member_candidates
    excluded_user_ids =
      User::Human.
      unscoped.joins('LEFT JOIN teammembers ON users.id = teammembers.user_id').
      where('users.username = "root" OR teammembers.team_id = ?', id).
      distinct.
      pluck(:id)
    User::Human.where('id NOT IN(?)', excluded_user_ids)
  end

  def remove_user(user)
    teammember(user.id).destroy!
  end

  def self.policy_class
    TeamPolicy
  end
end
