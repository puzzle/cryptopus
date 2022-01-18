# frozen_string_literal: true

class TeamFoldersEncryptablesSeeder

  def seed_team(name, members, admin = false)
    name = name.capitalize
    team = Team.seed_once(:name) do |t|
      t.name = name
      t.description = Faker::Lorem.paragraph
      t.private = !admin
    end.first

    (2..10).to_a.sample.times do
      seed_folder(team)
    end

    plaintext_team_pw = Crypto::Symmetric::AES256.random_key

    members.each do |m|
      u = user(m)
      add_member(team, u, plaintext_team_pw)
      add_member(team, root)
    end

    seed_encryptables(team)
  end

  def seed_encryptables(team)
    member = team.teammembers.first.user
    plaintext_private_key = member.decrypt_private_key('password')
    plaintext_team_pw = team.decrypt_team_password(member, plaintext_private_key)
    team.folders.each do |g|
      unless g.encryptables.present?
        (5..40).to_a.sample.times do
          seed_encryptable(g, plaintext_team_pw)
        end
      end
    end
  end

  def add_user_to_all_teams(user)
    [:john, :kate, :alice, :bruce, :emily].each do |teammember_name|
      teammember = User::Human.find_by(username: teammember_name)
      teammember.teams.each do |team|
        pk = Crypto::Symmetric::AES256.decrypt_with_salt(teammember[:private_key], 'password')
        decrypted_team_password = team.decrypt_team_password(teammember, pk)
        team.add_user(user, decrypted_team_password) unless team.teammember?(user.id)
      end
    end
  end

  private
  def user(username)
    User.find_by(username: username.to_s)
  end

  def root
    User.find_by(provider_uid: '0')
  end

  # provide team password for first member only
  def add_member(team, user, plaintext_team_pw = nil)
    return if team.teammember?(user.id)
    if team.teammembers.present?
      member = team.teammembers.first.user
      plaintext_private_key = member.decrypt_private_key('password')
      plaintext_team_pw = team.decrypt_team_password(member, plaintext_private_key)
    end
    team.add_user(user, plaintext_team_pw)
  end

  def seed_encryptable(folder, plaintext_team_pw)
    username = CryptUtils.encrypt_blob("#{Faker::Lorem.word} #{rand(999)}", plaintext_team_pw)
    password = CryptUtils.encrypt_blob(Faker::Internet.password, plaintext_team_pw)

    credential = folder.encryptables.new(name: "#{Faker::Company.name} #{rand(999)}",
                                  description: Faker::Lorem.paragraph,
                                      type: "Encryptable::Credentials")

    credential.encrypted_data[:username] = { data: username, iv: nil }
    credential.encrypted_data[:password] = { data: password, iv: nil }
    credential.save!
  end

  def seed_folder(team)
    Folder.seed do |f|
      f.name = "#{Faker::Lorem.word.capitalize} #{rand(999)}"
      f.team_id = team.id
    end
  end
end
