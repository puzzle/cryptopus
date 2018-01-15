class TeamPolicy < ApplicationPolicy

  def create?
    true
  end

  def update?
    user.admin? || record.teammember?(user.id)
  end

  def destroy?
    user.admin?
  end

  def last_teammember_teams?
    user.admin?
  end

  class Scope < Scope
    def resolve
      user.teams
    end
  end
end
