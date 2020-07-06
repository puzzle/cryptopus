# frozen_string_literal: true

# == Schema Information
#
# Table name: user_favourite_team
#
#  id         :integer          not null, primary key
#  team_id    :integer          default(0), not null
#  user_id    :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserFavouriteTeam < ApplicationRecord
  belongs_to :team
  belongs_to :user

  validates :user_id, uniqueness: { scope: :team }

  scope :list, (-> { joins(:user).order('users.username') })
end
