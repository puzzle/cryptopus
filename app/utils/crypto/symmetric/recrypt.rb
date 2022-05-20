# frozen_string_literal: true

class Crypto::Symmetric::Recrypt

  def initialize(team)
    update(team)
  end

  private

  def update(team)
    team_password = team.decrypt_team_password(current_user, session[:private_key])
    ActiveRecord::Base.transaction do
      entailed_encryptables(team).each do |encryptable|
        encryptable.recrypt(team_password, new_team_password)
      end

      update_team(team, new_team_password)
    end
  rescue
    team.recrypt_failed!
  end

  def update_team(team, new_team_password)
    update_team_encryption_algorithm(team)
    update_teammember_passwords(team, new_team_password)
    team.recrypt_done!
  end

  def update_teammember_passwords(team, new_team_password)
    team.teammembers.each do |member|
      update_teammember(member, new_team_password)
    end
  end

  def update_teammmeber(member, new_team_password)
    public_key = member.user.public_key
    encrypted_team_password = Crypto::RSA.encrypt(new_team_password, public_key)
    member.password = encrypted_team_password
    member.save!
  end

  def update_team_encryption_algorithm(team)
    team.update_encryption_algorithm
    team.save!
  end

  def encryptables_entailed_in(team)
    team.folders.map(&:encryptables).flatten
  end

  def new_team_password
    Team.default_encryption.random_key
  end

end
