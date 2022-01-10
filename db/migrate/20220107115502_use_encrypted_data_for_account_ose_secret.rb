# frozen_string_literal: true

class UseEncryptedDataForAccountOseSecret < ActiveRecord::Migration[6.1]
  def up
    Account::OSESecret.find_each do |s|
      parsed_data = parse_encrypted_data(s)
      secret_b64 = parsed_data[:value]
      iv_b64 = parsed_data[:iv]

      # decode values (as being encoded when set into encrypted_data again)
      ose_secret_data = Base64.strict_decode64(secret_b64)
      ose_secret_iv = Base64.strict_decode64(iv_b64)

      # clear encrypted_data
      # s.encrypted_data = nil

      # set new values into encrypted_data
      s.encrypted_data[:ose_secret] = { iv: ose_secret_iv, data: ose_secret_data }
      s.save!
    end
  end

  def down
    Account::OSESecret.find_each do |s|
      parsed_data = parse_encrypted_data(s)

      # check if account has been recrypted. :ose_secret key will be present
      if parsed_data.key?(:ose_secret)
        ose_secret = s.encrypted_data[:ose_secret]
        iv = Base64.strict_encode64(ose_secret[:iv])
        data = Base64.strict_encode64(ose_secret[:data])

        s.encrypted_data = { iv: iv, value: legacy_ose_secret_hash(data)}
        s.save!
      end

    end
  end

  def parse_encrypted_data(ose_secret_account)
    # read not casted json value of encrypted_data
    raw_encrypted_data = ose_secret_account.read_attribute_before_type_cast(:encrypted_data)

    # parse encrypted_data from json string
    JSON.parse(raw_encrypted_data, symbolize_names: true)
  end

  def legacy_ose_secret_hash(secret)
    # TODO: needs to be encrypted, not encoded. (problem: at this state is team_password not present)
    Base64.strict_encode64({ ose_secret: secret }.to_json)
  end
end

