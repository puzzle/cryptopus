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

class Team::Personal < Team
  belongs_to :personal_owner, class_name: 'User::Human', inverse_of: 'personal_team'

  class << self
    def create(owner)
      team = super(name: owner.username, personal_owner: owner, private: true)
      return team unless team.valid?

      plaintext_team_password = Crypto::Symmetric::Aes256.random_key
      team.add_user(owner, plaintext_team_password)

      team
    end
  end
end
