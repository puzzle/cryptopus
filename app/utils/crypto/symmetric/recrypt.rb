# frozen_string_literal: true

class Crypto::Symmetric::Recrypt

  class << self
    def recrypt_user_teams

    end

    def recrypt(team)

    end
  end

  private

  def recrypt_user_teams
    user_recrypt_teams.each do |team|
      team.recrypt_in_progress!
      new_team_password = team.encryption_algorithm_class.random_key
      recrypt(team, new_team_password)
    end

    jump_to = session.delete(:jumpto) || '/dashboard'
    redirect_to jump_to
  end

  def recrypt(team, new_team_password)
    team_password = team.decrypt_team_password(current_user, session[:private_key])
    ActiveRecord::Base.transaction do
      entailed_encryptables(team).each do |encryptable|
        recrypt_encryptable(encryptable, team_password, new_team_password)
      end

      recrypt_team(team, new_team_password)
    end
  rescue
    team.recrypt_failed!
  end

  def recrypt_team(team, new_team_password)
    update_team_encryption_algorithm(team)
    reset_teammember_passwords(team, new_team_password)
    team.recrypt_done!
  end

  def reset_teammember_passwords(team, new_team_password)
    team.teammembers.each do |member|
      public_key = member.user.public_key
      encrypted_team_password = Crypto::RSA.encrypt(new_team_password, public_key)
      member.password = encrypted_team_password
      member.save!
    end
  end

  def recrypt_encryptable(encryptable, team_password, new_team_password)
    encryptable.decrypt(team_password)
    encryptable.update_encryption_algorithm
    encryptable.encrypt(new_team_password)
    encryptable.save!
  end

  def update_team_encryption_algorithm(team)
    team.update_encryption_algorithm
    team.save!
  end

  def entailed_encryptables(team)
    team.folders.map(&:encryptables).flatten
  end

  def authorize_action(action)
    authorize action, policy_class: Recrypt::EncryptablesPolicy
  end
end
