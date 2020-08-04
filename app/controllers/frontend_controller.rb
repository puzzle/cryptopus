# frozen_string_literal: true

class FrontendController < ApplicationController

  layout false

  def index
    skip_authorization
    render file: Rails.root.join('public/frontend-index.html')
  end

end
