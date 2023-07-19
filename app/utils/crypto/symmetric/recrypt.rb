# frozen_string_literal: true

class Crypto::Symmetric::Recrypt

  def initialize(current_user, team, private_key)
    @current_user = current_user
    @team = team
    @private_key = private_key
  end

  def perform
    return if already_recrypted? || recrypt_locked?

    @team.recrypt_in_progress!
    @team_password = @team.decrypt_team_password(@current_user, @private_key)
    @new_team_password = @team.new_team_password

    begin
      recrypt
    rescue => e # rubocop:disable Style/RescueStandardError
      @team.recrypt_failed!
      raise "Recrypt failed: #{e.message}"
    end
  end

  private

  def already_recrypted?
    Crypto::Symmetric.latest_algorithm?(@team)
  end

  def recrypt_locked?
    @team.recrypt_in_progress? || @team.recrypt_failed?
  end

  def recrypt
    ActiveRecord::Base.transaction do
      @team.encryptables.find_each do |encryptable|
        encryptable.recrypt(@team_password, @new_team_password, latest_encryption_class)
      end

      update_team
    end
  end

  def update_team
    @team.teammembers.find_each do |member|
      member.reset_team_password(@new_team_password)
    end

    @team.encryption_algorithm = ::Crypto::Symmetric::LATEST_ALGORITHM
    @team.recrypt_done!
  end

  def latest_encryption_class
    encryption_algorithm = ::Crypto::Symmetric::LATEST_ALGORITHM
    Crypto::Symmetric::ALGORITHMS[encryption_algorithm]
  end

end
