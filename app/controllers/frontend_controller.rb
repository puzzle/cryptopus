# frozen_string_literal: true

class FrontendController < ApplicationController

  layout false

  def index
    skip_authorization
  end

end
