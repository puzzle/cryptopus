class UseEncryptedDataForAccountCredentials < ActiveRecord::Migration[6.1]
  def up
    change_column :accounts, :encrypted_data, :text, limit: 16.megabytes - 1
    rename_column :accounts, :accountname, :name

    Account.reset_column_information

    Account::Credentials.find_each do |a|
      # some blob values were set to "" that's why we're using .presence here
      a.encrypted_data[:password] = { iv: nil, data: a.password.presence }
      a.encrypted_data[:username] = { iv: nil, data: a.username.presence }
      a.save!
    end

    remove_column :accounts, :password
    remove_column :accounts, :username
  end

  def down
    add_column :accounts, :password, :binary
    add_column :accounts, :username, :binary

    Account.reset_column_information

    Account::Credentials.find_each do |a|
      a.password = a.encrypted_data[:password].try(:[], :data)
      a.username = a.encrypted_data[:username].try(:[], :data)
      a.encrypted_data = nil
      a.save!
    end

    rename_column :accounts, :name, :accountname
    change_column :accounts, :encrypted_data, :text

    # rename_table :accounts, :encryptables
    #
    # change_table :encryptables do |t|
    #   t.rename :name, :name
    # end
  end

  private

  module LegacyAccount
    class Credentials < Account
      self.table_name = 'accounts'
      self.inheritance_column = 'Account::Credentials'

      attr_accessor :cleartext_password, :cleartext_username

      def decrypt(team_password)
        @cleartext_username = decrypt_attr(:username, team_password)
        @cleartext_password = decrypt_attr(:password, team_password)
      end

      private

      def decrypt_attr(attr, team_password)
        crypted_value = send(attr)
        return if crypted_value.blank?

        CryptUtils.decrypt_blob(crypted_value, team_password)
      end
    end
  end

end
