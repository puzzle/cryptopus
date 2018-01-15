class TeamPolicy < ApplicationPolicy
  def initialize(user, team)
    @user = user
    @team = team
  end

  def create?
    true
  end

  def update?
    @user.admin? || @team.teammember?(@user.id)
  end

  def destroy?
    @user.admin?
  end

  def last_teammember_teams?
    @user.admin?
  end

  class Scope < Scope
    def initialize(user, team)
      @user = user
      @scope = team
    end

    def resolve
      @user.teams
    end
  end
end
