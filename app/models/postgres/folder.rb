# frozen_string_literal: true

class Folder < Folder
  include PgSearch::Model
  multisearchable against: [:name]
end