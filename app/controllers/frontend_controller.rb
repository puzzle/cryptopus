# frozen_string_literal: true

class FrontendController < ApplicationController

  layout false

  def index
    skip_authorization
    index_file = Rails.env.test? ? 'index-test' : 'index'
    render file: Rails.root.join("public/frontend-#{index_file}.html")
  end

end
