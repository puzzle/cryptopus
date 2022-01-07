# frozen_string_literal: true

class UseEncryptedDataForAccountOseSecret < ActiveRecord::Migration[6.1]
    def up
      Account::OSESecret.find_each do |s|
        # read not casted json value of encrypted_data
        raw_encrypted_data = s.read_attribute_before_type_cast(:encrypted_data)

        # parse values from json string
        secret_b64 = JSON.parse(raw_encrypted_data)["value"]
        iv_b64 = JSON.parse(raw_encrypted_data)["iv"]

        # decode values
        ose_secret_data = Base64.strict_decode64(secret_b64)
        ose_secret_iv = Base64.strict_decode64(iv_b64)

        # clear encrypted_data
        s.encrypted_data = nil

        # set new values into encrypted_data
        s.encrypted_data[:ose_secret] = { iv: ose_secret_iv, data: ose_secret_data }
        s.save!
      end
    end

    def down
      # Account::OSESecret.find_each do |a|
      #   a.password = a.encrypted_data[:password].try(:[], :data)
      #   a.username = a.encrypted_data[:username].try(:[], :data)
      #   a.encrypted_data = nil
      #   a.save!
      # end
    end

  end

