# frozen_string_literal: true

class ProfileController < ApplicationController
  def index
    skip_authorization
  end
end
