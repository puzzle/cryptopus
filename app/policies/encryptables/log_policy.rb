# frozen_string_literal: true

class Encryptables::LogPolicy < TeamDependantPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    return true if @user.is_a?(User::Human)
  end
end
