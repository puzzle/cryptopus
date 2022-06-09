# frozen_string_literal: true

class Crypto::Symmetric::Recrypt

  def initialize(current_user, team, private_key)
    @current_user = current_user
    @team = team
    @private_key = private_key
  end

  def perform
    return if already_recrypted? || recrypt_locked?

    prepare_recrypt
    begin
      ActiveRecord::Base.transaction do

        recrypt(@team.new_team_password)
      end
    rescue => e # rubocop:disable Style/RescueStandardError
      # TODO: Notify sentry
      @team.recrypt_failed!
      raise "Recrypt failed: #{e.message}"
    end
  end

  private

  def prepare_recrypt
    @team.recrypt_in_progress!
    @team_password = @team.decrypt_team_password(@current_user, @private_key)
  end

  def already_recrypted?
    Crypto::Symmetric.latest_algorithm?(@team)
  end

  def recrypt_locked?
    @team.recrypt_in_progress? || @team.recrypt_failed?
  end

  def recrypt(new_team_password)
    recrypt_team_encryptables(new_team_password)
    update_team(new_team_password)
  end

  def recrypt_team_encryptables(new_team_password)
    @team.encryptables.find_each do |encryptable|
      encryptable.recrypt(@team_password, new_team_password)
    end
  end

  def update_team(new_team_password)
    update_team_encryption_algorithm
    update_teammember_passwords(new_team_password)
    @team.recrypt_done!
  end

  def update_teammember_passwords(new_team_password)
    @team.teammembers.find_each do |member|
      update_teammeber(member, new_team_password)
    end
  end

  def update_teammeber(member, new_team_password)
    public_key = member.user.public_key
    encrypted_team_password = Crypto::Rsa.encrypt(new_team_password, public_key)
    member.encrypted_team_password = encrypted_team_password
    member.save!
  end

  def update_team_encryption_algorithm
    @team.update_encryption_algorithm
    @team.save!
  end

end
