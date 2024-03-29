# frozen_string_literal: true

class EncryptableMoveHandler < EncryptableHandler

  attr_accessor :new_folder

  def move
    ApplicationRecord.transaction do
      move_account_to_new_team unless same_team?

      raise ActiveRecord::Rollback unless encryptable.valid?
    end
  end

  private

  def move_account_to_new_team
    raise 'user is not member of new team' unless new_team.teammember?(user.id)

    old_team_password = old_team.decrypt_team_password(user, private_key)
    move_encryptable_files(old_team_password)
    encryptable.encrypt(new_team.decrypt_team_password(user, private_key))
  end

  def move_encryptable_files(old_team_password)
    new_team_password = new_team.decrypt_team_password(user, private_key)
    encryptable.encryptable_files.each do |f|
      f.decrypt(old_team_password)
      f.encrypt(new_team_password)
      f.save!
    end
  end

  def same_team?
    old_team == new_team
  end

  def new_team
    @new_team ||= encryptable.folder.team
  end

  def old_team
    @old_team ||= Folder.find(encryptable.folder_id_was).team
  end
end
