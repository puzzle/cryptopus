# frozen_string_literal: true

class FilteredList

  def initialize(current_user, params)
    @current_user = current_user
    @params = params
  end

  def fetch_entries
    raise NotImplementedError, 'implement in subclass'
  end
end
