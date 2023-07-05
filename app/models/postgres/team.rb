# frozen_string_literal: true

class Postgres::Team
  def initialize()
    Team.class_eval do
      include PgSearch::Model
      multisearchable against: [:name]
    end
  end
end

