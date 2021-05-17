# frozen_string_literal: true

module ParamConverters

  private

  def true?(value)
    %w[1 yes true].include?(value.to_s.downcase)
  end
end
