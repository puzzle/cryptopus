# frozen_string_literal: true
class Encryptable < Encryptable
  include PgSearch::Model
  multisearchable against: [:name]
end

