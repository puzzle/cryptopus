# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module ControllerHelpers
  def login_as(username, password = 'password')
    user = User::Human.find_by(username: username)
    request.session[:user_id] = user.id
    session[:private_key] = CryptUtils.decrypt_private_key(user.private_key, password)
  end

  def json
    JSON.parse(response.body)
  end

  def data
    json['data']
  end

  def expect_json_object_includes_keys(json, keys)
    keys.each do |k|
      expect(json).to include(k)
    end
  end

  def errors
    json['errors']
  end
end
