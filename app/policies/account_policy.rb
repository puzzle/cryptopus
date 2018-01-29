class AccountPolicy < TeamDependantPolicy
  def show?
    team_member?
  end

  def new?
    team_member?
  end

  def create?
    team_member?
  end

  def create_item?
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

  def move?
    team_member?
  end

  protected

  def team
    account.group.team
  end

  private

  def current_user
    @user
  end

  def account
    @record
  end

  class Scope < TeamDependantScope
    def resolve
      if team_member?
        @scope.accounts.all
      end
    end

    protected

    def team
      @scope.team
    end
  end
end
