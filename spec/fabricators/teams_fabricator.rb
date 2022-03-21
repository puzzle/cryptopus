# frozen_string_literal: true

require_relative '../../app/utils/crypto/symmetric/aes256'

Fabricator(:non_private_team, from: :team) do |t|
  t.name { Faker::App.name }
  t.description { Faker::Hacker.say_something_smart }
  t.visible true
  t.private false
  after_save do |team|
    team_password = Crypto::Symmetric::AES256.random_key
    team.add_user(Fabricate(:user), team_password)
    User::Human.admins.each do |a|
      team.add_user(a, team_password)
    end
    folder = Fabricate(:folder, team: team)
    Fabricate(:credential, folder: folder, team_password: team_password)
  end
end

Fabricator(:private_team, from: :team) do |t|
  t.name { Faker::App.name }
  t.description { Faker::Hacker.say_something_smart }
  t.visible true
  t.private true
  after_save do |team|
    team_password = Crypto::Symmetric::AES256.random_key
    team.add_user(Fabricate(:user), team_password)
    folder = Fabricate(:folder, team: team)
    Fabricate(:credential, folder: folder, team_password: team_password)
  end
end
