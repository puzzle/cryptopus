class Team::ApiUser < ActiveModelSerializers::Model

  delegate :id,
           :username,
           :valid_for,
           to: :@api_user

  def self.list(current_user, team)
    current_user.api_users.collect do |a|
      Team::ApiUser.new(a, team)
    end
  end

  def initialize(api_user, team)
    @api_user = api_user
    @team = team
  end

  def enabled?
    @team.teammember?(@api_user)
  end

  def enable(plaintext_team_password)
    @team.add_user(@api_user, plaintext_team_password)
  end

  def disable
    @team.remove_user(@api_user)
  end
end
