# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

Fabricator(:non_private_team, from: :team) do |t|
  t.name { Faker::App.name }
  t.description { Faker::Hacker.say_something_smart }
  t.visible true
  t.private false
  after_save do |team|
    #generate password, add user, add group, and add account after save
    team_password = CryptUtils.new_team_password
    team.add_user(Fabricate(:user), team_password)
    group = Fabricate(:group)
    group.save
    account = Account.new()
    account.accountname = Faker::Team.creature
    account.cleartext_username = Faker::Internet.user_name
    account.cleartext_password = Faker::Internet.password
    account.encrypt(team_password)
    account.save!
  end
end

Fabricator(:private_team, from: :non_private_team) do |t|
  t.private true
end
