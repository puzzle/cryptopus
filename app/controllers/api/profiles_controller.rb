# frozen_string_literal: true

class Api::ProfilesController < ApiController
  skip_before_action :validate_user
  before_action :skip_authorization

  self.permitted_attrs = [:preferred_locale]

  def update
    return unless current_user.is_a?(User::Human)

    current_user.attributes = model_params
    if current_user.save
      head :ok
    else
      render_errors
    end
  end
end
