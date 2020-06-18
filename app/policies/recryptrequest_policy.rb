# frozen_string_literal: true

class RecryptrequestPolicy < ApplicationPolicy
  def index?
    current_user.admin?
  end

  def destroy?
    current_user.admin?
  end

  private

  def current_user
    @user
  end
end
