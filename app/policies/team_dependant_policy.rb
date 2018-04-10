class TeamDependantPolicy < ApplicationPolicy
  def show?
    team.teammember?(@user.id)
  end

  def new?
    team_member?
  end

  def create?
    team_member?
  end

  def edit?
    team_member?
  end

  def update?
    team_member?
  end

  def destroy?
    team_member?
  end

  def team_member?
    @user.is_a?(User::Human) && team.teammember?(@user.id)
  end

  protected

  def team
    raise 'implement in subclass'
  end

  class TeamDependantScope < Scope
    def team_member?
      team.teammember?(@user.id)
    end

    protected

    def team
      raise 'Implement in subclass'
    end
  end
end
