# frozen_string_literal: true

class FilteredList

  def initialize(entries, params)
    @entries = entries
    @params = params
  end

  def filter
    raise NotImplementedError, 'implement in subclass'
  end
end

