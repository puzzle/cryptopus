# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

Fabricator(:account) do
  transient :team_password
  accountname { Faker::Team.creature }
  cleartext_username { Faker::Internet.user_name }
  cleartext_password { Faker::Internet.password }
  before_save do |account, attrs|
    account.encrypt(attrs[:team_password])
  end
end
