# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require Rails.root.join('db', 'seeds', 'support', 'team_groups_accounts_seeder')

seeder = TeamGroupsAccountsSeeder.new

%i[mail shops distributors].each do |n|
  users = %i[alice bob]
  seeder.seed_team(n, users)
end

%i[web infrastructure].each do |n|
  users = %i[john kate alice bruce emily]
  seeder.seed_team(n, users, true)
end

[:finance].each do |n|
  users = %i[kate alice]
  seeder.seed_team(n, users, false)
end

%i[org government].each do |n|
  users = %i[kate bruce emily]
  seeder.seed_team(n, users, true)
end

[:'alice private'].each do |n|
  users = %i[alice]
  seeder.seed_team(n, users, false)
end
