# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Item < ActiveRecord::Base
  belongs_to :account
  validates :filename, uniqueness: { scope: :account }
  validates :filename, presence: true


  def label
    filename
  end

  def decrypt_file(file, team_password)
    CryptUtils.decrypt_blob(file, team_password)
  end

  def encrypt_file(file, team_password)
     CryptUtils.encrypt_blob(file, team_password)
  end

end
