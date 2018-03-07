class AccountPolicy < TeamDependantPolicy
  def create_item?
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

    def resolve_all
      @user.accounts
    end

    protected

    def team
      @scope.team
    end
  end
end
