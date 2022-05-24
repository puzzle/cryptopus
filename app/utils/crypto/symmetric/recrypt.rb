# frozen_string_literal: true

class Crypto::Symmetric::Recrypt

  def initialize(current_user, team, private_key)
    @current_user = current_user
    @team = team
    @private_key = private_key

    perform
  end

  private

  def perform
    return if Crypto::EncryptionAlgorithm.latest_in_use?(@team)

    @team.recrypt_in_progress!
    team_password = @team.decrypt_team_password(@current_user, @private_key)

    begin
      ActiveRecord::Base.transaction do
        recrypt(team_password, new_team_password)
      end
    rescue => e
      # TODO: Notify sentry
      @team.recrypt_failed!

      raise "Recrypt failed: #{e.message}"
    end
  end

  def recrypt(team_password, new_team_password)
    entailed_encryptables.each do |encryptable|
      encryptable.recrypt(team_password, new_team_password)
    end

    update_team(new_team_password)
  end

  def update_team(new_team_password)
    update_team_encryption_algorithm
    update_teammember_passwords(new_team_password)
    @team.recrypt_done!
  end

  def update_teammember_passwords(new_team_password)
    @team.teammembers.each do |member|
      update_teammeber(member, new_team_password)
    end
  end

  def update_teammeber(member, new_team_password)
    public_key = member.user.public_key
    encrypted_team_password = Crypto::Rsa.encrypt(new_team_password, public_key)
    member.password = encrypted_team_password
    member.save!
  end

  def update_team_encryption_algorithm
    @team.update_encryption_algorithm
    @team.save!
  end

  def entailed_encryptables
    @team.folders.map(&:encryptables).flatten
  end

  def new_team_password
    Crypto::EncryptionAlgorithm.get_class(@team.encryption_algorithm).random_key
  end

end
