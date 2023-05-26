class AddPersonalInboxToFolders < ActiveRecord::Migration[7.0]
  def up
    add_column :folders, :personal_inbox, :boolean, default: false, null: false

    Team::Personal.find_each do |t|
      folder = t.folders.find_by(name: 'inbox')
      folder&.update!(personal_inbox: true)
    end
  end

  def down
    remove_column :folders, :personal_inbox, :boolean
  end
end
