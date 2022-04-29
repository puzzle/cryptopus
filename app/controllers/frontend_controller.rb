# frozen_string_literal: true

class FrontendController < ApplicationController

  layout false

  include RenderFrontend

  def index
    skip_authorization
    render_frontend
  end

end
