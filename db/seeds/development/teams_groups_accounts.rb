require Rails.root.join('db', 'seeds', 'support', 'team_groups_accounts_seeder')

seeder = TeamGroupsAccountsSeeder.new

[:mail, :shops, :distributors].each do |n|
  users = [:alice, :bob]
  seeder.seed_team(n, users)
end

[:web, :infrastructure].each do |n|
  users = [:john, :kate, :alice, :bruce, :emily]
  seeder.seed_team(n, users, true)
end

[:finance].each do |n|
  users = [:kate, :alice]
  seeder.seed_team(n, users, false, true)
end

[:org, :government].each do |n|
  users = [:kate, :bruce, :emily]
  seeder.seed_team(n, users, true, true)
end

[:'alice private'].each do |n|
  users = [:alice]
  seeder.seed_team(n, users, false, false)
end
