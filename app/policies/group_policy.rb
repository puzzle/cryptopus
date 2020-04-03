# frozen_string_literal: true

class GroupPolicy < TeamDependantPolicy
  def index?
    true
  end

  def show?
    team_member?
  end

  private

  def team
    group.team
  end

  def group
    @record
  end
end
