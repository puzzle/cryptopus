# frozen_string_literal: true
class Team < Team
  include PgSearch::Model
  multisearchable against: [:name]
end

