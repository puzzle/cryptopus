# frozen_string_literal: true

class RedirectedRoutesController < ApplicationController

  layout false

  include RenderFrontend

  def redirect
    skip_authorization

    if url_handler.frontend_path?
      render_frontend
    else
      raise ActionController::RoutingError, 'Not Found' if request.path == url_handler.redirect_to

      redirect_to url_handler.redirect_to
    end
  end

  private

  def url_handler
    @url_handler ||= RedirectedRoutes::UrlHandler.new(request.path)
  end

end
