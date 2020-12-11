# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require Rails.root.join('db', 'seeds', 'support', 'team_folders_accounts_seeder')

seeder = TeamFoldersAccountsSeeder.new

50.times do
  users = [:john, :kate, :alice, :bruce, :emily].sample(3)
  seeder.seed_team("#{Faker::Job.field} #{rand(999)}", users, [true, false].sample)
end
