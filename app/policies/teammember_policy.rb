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
    team.id == @user.personal_team_id
  end

  def team
    @record.team
  end
end