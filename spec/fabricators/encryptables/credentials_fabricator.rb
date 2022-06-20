# frozen_string_literal: true

Fabricator(:credential, from: 'Encryptable::Credentials') do
  transient :team_password
  name { Faker::Team.creature }
  cleartext_username { Faker::Internet.user_name }
  cleartext_password { Faker::Internet.password }
  before_save do |encryptable, attrs|
    encryptable.encrypt(attrs[:team_password])
  end
end

Fabricator(:file, from: 'Encryptable::File') do
  transient :team_password
  name { Faker::File.file_name }
  cleartext_file { Faker::Hacker.say_something_smart }
  before_save do |encryptable, attrs|
    encryptable.encrypt(attrs[:team_password])
  end
end
