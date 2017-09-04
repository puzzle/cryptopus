# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

# Be sure to restart your server when you modify this file.
def initialize_secret
  # Only generate token based if we're running on OPENSHIFT
  secret = ENV['OPENSHIFT_SECRET_TOKEN']
  if secret
    # Create seed for random function from secret and name
    seed = [secret, 'e2944b259f43436aba45be8cbbd32'].join('-')
    # Generate hash from seed
    hash = Digest::SHA512.hexdigest(seed)
    hash[0, 128]
  else
    ENV['RAILS_SECRET_TOKEN'] ||
      '77ce7c8203032b6c9cc62b3ac8ab12744ef5ef387604f3409ed0bd5ba3599ff5b8780283d6391d88ac9fe1691b842a7d00a4ba83fd2973a22ad80e175967e391'
  end
end

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Cryptopus::Application.config.secret_key_base = initialize_secret
