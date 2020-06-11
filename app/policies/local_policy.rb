# frozen_string_literal: true

class LocalPolicy < ApplicationPolicy

  def new?
    user.nil?
  end

  def create?
    user.nil?
  end
end
