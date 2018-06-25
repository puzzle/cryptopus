class SearchPolicy < ApplicationPolicy

  def index?
    user.present?
  end

end
