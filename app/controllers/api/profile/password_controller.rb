# frozen_string_literal: true

class Api::Profile::PasswordController < ApiController
  self.permitted_attrs = [:old_password, :new_password1, :new_password2]

  def update
    authorize current_user, :update_password?
    if password_params_valid?
      current_user.update_password(old_password,
                                   new_password)
      add_info('flashes.profile.changePassword.success')
      ok_status = 200
    end
    render_json(nil, ok_status || 400)
  end

  def password_params_valid?
    unless current_user.authenticate_db(old_password)
      add_error('helpers.label.user.wrongPassword')
      return false
    end

    unless new_passwords_match?
      add_error('flashes.profile.changePassword.new_passwords_not_equal')
      return false
    end
    true
  end

  private

  def old_password
    model_params[:old_password]
  end

  def new_password
    model_params[:new_password1] if new_passwords_match?
  end

  def new_passwords_match?
    model_params[:new_password1] == model_params[:new_password2]
  end
end
