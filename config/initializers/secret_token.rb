# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Cryptopus::Application.config.secret_token = 'cb9438a76f50e97603412fcd2f061b3577ce3d7c91a5d8812c83bdaa6ec09f5187b9c7fbb18d07fec3f63d80de87e16325a10246461169dd55b777151a1baa7e'

Cryptopus::Application.config.secret_key_base = if Rails.env.development? or Rails.env.test?
  ('a' * 30)
else
  ENV['SECRET_TOKEN']
end