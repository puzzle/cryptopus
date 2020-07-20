# frozen_string_literal: true

class Api::EnvSettingsController < ApiController
  include ApplicationHelper

  skip_before_action :validate_user
  before_action :skip_authorization

  def index
    render_json(sentry: ENV['SENTRY_DSN_FRONTEND'],
                current_user: { id: current_user.id,
                                givenname: current_user.givenname,
                                preferred_locale: current_user.preferred_locale },
                version: version_number)
  end
end
