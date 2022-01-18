# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class EncryptableHandler

  attr_accessor :encryptable, :private_key, :user

  def initialize(encryptable, private_key, user)
    @encryptable = encryptable
    @private_key = private_key
    @user = user
  end

end
