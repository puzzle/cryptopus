require Rails.root.join('db', 'seeds', 'support', 'user_seeder')

seeder = UserSeeder.new

seeder.seed_root

seeder.seed_users([:alice, :bob, :john, :kate])

seeder.seed_admins([:bruce, :emily])
