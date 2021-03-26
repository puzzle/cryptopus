# frozen_string_literal: true

module UserProfileHelper

  def user_otp_qr_code
    qr_code = OneTimePassword.new(current_user.username).
              provisioning_qr_code
    base64_data = Base64.encode64(qr_code.to_blob)
    "data:image/png;base64,#{base64_data}"
  end

end
