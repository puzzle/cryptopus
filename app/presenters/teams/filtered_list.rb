# frozen_string_literal: true

module Teams
  class FilteredList < ::FilteredList

    def filter
      if query.present?
        return entries.where('name like ?', "%#{query}%")
      end

      entries
    end

    def query
      @params[:q]
    end

    def team_ids
      @params[:team_ids]
    end

    attr_reader :entries
  end
end
