require Rails.root.join('db', 'seeds', 'support', 'user_seeder')

seeder = UserSeeder.new

seeder.seed_root('cryptopus')
