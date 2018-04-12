class AccountPolicy < TeamDependantPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def show?
    team.teammember?(@user.id)
  end

  def create_item?
    team_member?
  end

  def move?
    team_member?
  end

  protected

  def team
    @record.group.team
  end

  class Scope < TeamDependantScope

    def resolve
      @user.accounts
    end

    protected

    def team
      @scope.team
    end
  end
end
