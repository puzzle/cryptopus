# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module UserProfilesHelper

  def user_otp_qr_code
    qr_code = OneTimePassword.new(current_user.username).
      provisioning_qr_code
    base64_data = Base64.encode64(qr_code.to_blob)
    "data:image/png;base64,#{base64_data}"
  end

end
