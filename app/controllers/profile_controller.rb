class ProfileController < ApplicationController
  def index
    skip_authorization
  end
end
