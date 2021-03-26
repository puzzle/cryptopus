# frozen_string_literal: true

class ProfileController < ApplicationController
  def index
    skip_authorization
  end

  def totp_enable
    skip_authorization
    current_user.update!(second_factor_auth: :totp)
    redirect_to profile_path
  end

  def totp_disable
    skip_authorization
    current_user.update!(second_factor_auth: :no_second_factor)
    redirect_to profile_path
  end
end
