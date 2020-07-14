# frozen_string_literal: true

class Api::LocaleController < ApiController
  skip_before_action :validate_user
  before_action :skip_authorization

  self.permitted_attrs = [:preferred_locale]

  def update
    current_user.attributes = model_params
    if current_user.save
      head 200
    else
      render_errors
    end
  end
end
