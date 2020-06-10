# frozen_string_literal: true

class Api::EnvSettingsController < ApiController

  skip_before_action :validate_user
  before_action :skip_authorization

  def index
    render_json sentry: ENV['SENTRY_DSN_FRONTEND']
  end
end
