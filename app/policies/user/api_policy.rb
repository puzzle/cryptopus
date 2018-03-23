class User::ApiPolicy < ApplicationPolicy
  def create?
    true
  end

  def show?
    api_user?
  end

  def update?
    api_user?
  end

  def destroy?
    api_user?
  end

  def permitted_attributes_for_update
    %i[locked options]
  end

  def permitted_attributes_for_create
    %i[username password human_user_id options]
  end

  private

  def api_user?
    @user.api_user?(@record.id)
  end

  class Scope < Scope
    def resolve
      @user.apis
    end
  end
end
