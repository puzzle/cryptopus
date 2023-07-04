# frozen_string_literal: true

Fabricator(:non_private_team, from: :team) do |t|
  t.name { Faker::App.name }
  t.description { Faker::Hacker.say_something_smart }
  t.visible true
  t.private false
  t.type Team::Shared
  after_create do |team|
    team_password = team.new_team_password
    team.add_user(Fabricate(:user), team_password)
    User::Human.admins.each do |a|
      team.add_user(a, team_password)
    end
    folder = Fabricate(:folder, team: team)
    Fabricate(:credential_all_attrs, folder: folder, team_password: team_password)
  end
end

Fabricator(:old_encryption_algo_team, from: :team) do |t|
  t.name { Faker::App.name }
  t.description { Faker::Hacker.say_something_smart }
  t.visible true
  t.private false
  t.type Team::Shared
  t.encryption_algorithm 'AES256'
  after_create do |team|
    team_password = team.new_team_password
    team.add_user(Fabricate(:user), team_password)
    User::Human.admins.each do |a|
      team.add_user(a, team_password)
    end
    folder = Fabricate(:folder, team: team)
    Fabricate(:credential_one_attr, folder: folder, team_password: team_password)
    Fabricate(:credential_no_attr, folder: folder, team_password: team_password)
  end
end

Fabricator(:private_team, from: :team) do |t|
  t.name { Faker::App.name }
  t.description { Faker::Hacker.say_something_smart }
  t.visible true
  t.private true
  t.encryption_algorithm 'AES256IV'
  t.type Team::Shared
  after_create do |team|
    team_password = team.new_team_password
    team.add_user(Fabricate(:user), team_password)
    folder = Fabricate(:folder, team: team)
    Fabricate(:credential_all_attrs, folder: folder, team_password: team_password)
  end
end
