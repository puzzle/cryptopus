# frozen_string_literal: true

module RenderFrontend
  extend ActiveSupport::Concern

  def render_frontend
    render file: frontend_file
  end

  private

  def frontend_file
    index_name = 'index'

    if Rails.env.test? && File.exist?(file_path('index-test'))
      index_name = 'index-test'
    end

    if Rails.env.development?
      index_name = 'index-development'
    end

    file_path(index_name)
  end

  def file_path(index_name)
    Rails.root.join("public/frontend-#{index_name}.html")
  end

end
