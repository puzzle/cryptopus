# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

Fabricator(:credential_all_attrs, from: 'Encryptable::Credentials') do
  transient :team_password
  name { Faker::Team.creature }
  cleartext_username { Faker::Internet.user_name }
  cleartext_password { Faker::Internet.password }
  cleartext_token { Faker::Internet.uuid }
  cleartext_pin { Faker::Internet.ip_v4_address }
  cleartext_email { Faker::Internet.email }
  cleartext_custom_attr_label { Faker::Internet.user_name }
  cleartext_custom_attr { Faker::Internet.password }
  before_create do |encryptable, attrs|
    encryptable.encrypt(attrs[:team_password])
  end
end

Fabricator(:credential_one_attr, from: 'Encryptable::Credentials') do
  transient :team_password
  name { Faker::Team.creature }
  cleartext_token { Faker::Internet.uuid }
  before_create do |encryptable, attrs|
    encryptable.encrypt(attrs[:team_password])
  end
end

Fabricator(:credential_no_attr, from: 'Encryptable::Credentials') do
  transient :team_password
  name { Faker::Team.creature }
  before_create do |encryptable, attrs|
    encryptable.encrypt(attrs[:team_password])
  end
end

Fabricator(:file, from: 'Encryptable::File') do
  transient :team_password
  name { Faker::File.file_name }
  cleartext_file { Faker::Hacker.say_something_smart }
  before_create do |encryptable, attrs|
    encryptable.encrypt(attrs[:team_password])
  end
end
