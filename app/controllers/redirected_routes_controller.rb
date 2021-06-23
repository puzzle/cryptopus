# frozen_string_literal: true

class RedirectedRoutesController < ApplicationController

  layout false

  def redirect
    skip_authorization

    if url_handler.frontend_path?
      render file: frontend_file
    else
      raise ActionController::RoutingError, 'Not Found' if request.path == url_handler.redirect_to

      redirect_to url_handler.redirect_to
    end
  end

  private

  def url_handler
    @url_handler ||= RedirectedRoutes::UrlHandler.new(request.path)
  end

  def frontend_file
    index_name = 'index'

    if Rails.env.test? && File.exist?(file_path('index-test'))
      index_name = 'index-test'
    end

    file_path(index_name)
  end

  def file_path(index_name)
    Rails.root.join("public/frontend-#{index_name}.html")
  end
end
