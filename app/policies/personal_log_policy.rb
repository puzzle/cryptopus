# frozen_string_literal: true

class PersonalLogPolicy < TeamPolicy
  def index?
    current_user.is_a?(User::Human)
  end
end
