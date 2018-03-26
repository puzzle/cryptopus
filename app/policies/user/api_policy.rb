class User::ApiPolicy < ApplicationPolicy
  def create?
    true
  end

  def show?
    own_api_user?
  end

  def update?
    own_api_user?
  end

  def destroy?
    own_api_user?
  end

  def permitted_attributes_for_update
    %i[description valid_for]
  end

  def permitted_attributes_for_create
    %i[description valid_for]
  end

  private

  def own_api_user?
    @record.human_user_id == @user.id
  end

  class Scope < Scope
    def resolve
      @user.api_users
    end
  end
end
