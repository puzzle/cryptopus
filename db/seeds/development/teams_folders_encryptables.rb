# frozen_string_literal: true

require Rails.root.join('db', 'seeds', 'support', 'team_folders_encryptables_seeder')

seeder = TeamFoldersEncryptablesSeeder.new

50.times do
  users = [:john, :kate, :alice, :bruce, :emily].sample(3)
  seeder.seed_team("#{Faker::Job.field} #{rand(999)}", users, [true, false].sample)
end

folder_ids = Team.order(:name).limit(1).first.folders.pluck(:id)
Encryptable::Credentials.where(folder_id: folder_ids).each do |c|
  seeder.seed_file(c)
end
