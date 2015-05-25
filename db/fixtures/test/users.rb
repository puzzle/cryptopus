User.seed_once(:uid) do |u|
  u.uid = 0
  u.username = 'root'
  u.givenname = 'root'
  u.auth = 'db'
  u.password = CryptUtils.one_way_crypt('password')
  keypair = CryptUtils.new_keypair
  uncrypted_private_key = CryptUtils.get_private_key_from_keypair(keypair)
  u.public_key = CryptUtils.get_public_key_from_keypair( keypair )
  u.private_key = CryptUtils.encrypt_private_key(uncrypted_private_key, 'password')
end
