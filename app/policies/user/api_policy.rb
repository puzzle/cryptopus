# frozen_string_literal: true

class User::ApiPolicy < ApplicationPolicy
  def index?
    user.is_a?(User::Human)
  end

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

  def lock?
    own_api_user?
  end

  def unlock?
    own_api_user?
  end

  private

  def own_api_user?
    @record.human_user_id == @user.id
  end
end
