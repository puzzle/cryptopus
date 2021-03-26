# frozen_string_literal: true

class TotpPolicy < ApplicationPolicy
  def new?
    true
  end

  def create?
    true
  end
end
