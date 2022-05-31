# frozen_string_literal: true

class TeammemberPolicy < TeamDependantPolicy

  def initialize(user, record)
    @user = user
    @record = record
  end

  def create?
    !personal_team? && super
  end

  def destroy?
    !personal_team? && super
  end

  private

  def personal_team?
    team.personal_team?
  end

  def team
    @record.team
  end
end
