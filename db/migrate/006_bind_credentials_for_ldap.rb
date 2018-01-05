# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class BindCredentialsForLdap < ActiveRecord::Migration[4.2]

  def change
    add_column :ldapsettings, :bind_dn, :string, default: nil
    add_column :ldapsettings, :bind_password, :string, default: nil
  end

end
