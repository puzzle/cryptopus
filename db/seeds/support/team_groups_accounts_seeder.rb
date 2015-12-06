class TeamGroupsAccountsSeeder

  def seed_team(name, members, admin = false, noroot = false)
    name = name.to_s.capitalize
    Team.seed_once(:name) do |t|
      t.name = name
      t.description = Faker::Lorem.paragraph
      t.groups = [Group.create(name: Faker::Lorem.word.capitalize)]
      t.private = !admin
      t.noroot = noroot
    end

    team = Team.find_by(name: name)

    members.each do |m|
      u = user(m)
      add_member(team, u)
      add_member(team, root) unless team.noroot
    end

    seed_accounts(team)
  end

  def seed_accounts(team)
    member = team.teammembers.first.user
    plaintext_private_key = member.decrypt_private_key('password')
    plaintext_team_pw = team.decrypt_team_password(member, plaintext_private_key)
    team.groups.each do |g|
      unless g.accounts.present?
        (1..15).to_a.sample.times do
          seed_account(g, plaintext_team_pw)
        end
      end
    end
  end

  private
  def user(username)
    User.find_by(username: username.to_s)
  end

  def root
    User.find_by(uid: 0)
  end

  def add_member(team, user)
    return if team.teammember?(user.id)
    plaintext_team_pw = nil
    if team.teammembers.present?
      member = team.teammembers.first.user
      plaintext_private_key = member.decrypt_private_key('password')
      plaintext_team_pw = team.decrypt_team_password(member, plaintext_private_key)
    end
    team.add_user(user, plaintext_team_pw)
  end

  def seed_account(group, plaintext_team_pw)
    username = CryptUtils.encrypt_blob(Faker::Lorem.word, plaintext_team_pw)
    password = CryptUtils.encrypt_blob(Faker::Internet.password, plaintext_team_pw)
    group.accounts.create!(accountname: Faker::Company.name,
                           username: username,
                           password: password,
                           description: Faker::Lorem.paragraph)
  end

end
