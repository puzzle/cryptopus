# frozen_string_literal: true

class SearchPolicy < ApplicationPolicy

  def index?
    user.present?
  end

end
