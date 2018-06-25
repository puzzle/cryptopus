# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require Rails.root.join('db', 'seeds', 'support', 'user_seeder')

seeder = UserSeeder.new

seeder.seed_root

seeder.seed_users([:alice, :bob, :john, :kate])

seeder.seed_conf_admins([:tux])

seeder.seed_admins([:bruce, :emily])
