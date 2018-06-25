# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module ControllerTest
  module DefaultHelper
    def login_as(username, password = 'password')
      user = User::Human.find_by_username(username)
      request.session[:user_id] = user.id
      session[:private_key] = CryptUtils.decrypt_private_key( user.private_key, password )
    end
  end
end
