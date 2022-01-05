# frozen_string_literal: true

require 'spec_helper'
mig_file = Dir[Rails.root.join('db/migrate/20220104140658_encryptables_data_structure.rb')].first
require mig_file

describe EncryptablesDataStructure do

  let(:migration) { described_class.new }
  let(:team_password1) { Base64.strict_decode64('LPTDTUOnL201Fn24GYP8ZRpE79m9ucBY8cF/tcCKcCs=') }
  let(:team_password2) { Base64.strict_decode64('LPTDTUOnL201Fn24GYP8ZRpE79m9ucBY8cF/tcCKcCs=') }

  let(:folder1) {folders(:folder1)}

  let(:account1) {accounts(:account1)}
  let(:account2) {accounts(:account2)}
  let!(:account3) { Account::Credentials.create!(name: 'spacex', folder: folder1, encrypted_data: {
    password: {data: '', iv: nil},
    username: {data: nil, iv: nil}
  })}

  def silent
    verbose = ActiveRecord::Migration.verbose = false

    yield

    ActiveRecord::Migration.verbose = verbose
  end

  around do |test|
    silent { test.run }
  end

  context 'up' do
    before { migration.down }

    it 'migrates blob credentials to base64' do
      migration.up

      account1.reload

      result = account1.read_attribute_before_type_cast(:encrypted_data)
      expect(result).to eq("{\"password\":{\"iv\":null,\"data\":\"pulO7xz5jDwUVQzbOqJzIw==\"},\"username\":{\"iv\":null,\"data\":\"0CkUu2Bd9eNB4OCuXVC3TA==\"}}")

      account1.decrypt(team_password1)

      expect(account1.cleartext_username).to eq('test')
      expect(account1.cleartext_password).to eq('password')

      account2.reload

      result = account2.read_attribute_before_type_cast(:encrypted_data)
      expect(result).to eq("{\"password\":{\"iv\":null,\"data\":\"X2i8woXXwIHew6zcnBws9Q==\"},\"username\":{\"iv\":null,\"data\":\"Kvkd66uUiNq4Gw4Yh7PvVg==\"}}")

      account2.decrypt(team_password2)

      expect(account2.cleartext_username).to eq('test')
      expect(account2.cleartext_password).to eq('password')

      account3.reload

      result = account3.read_attribute_before_type_cast(:encrypted_data)
      expect(result).to eq("{}")

      account3.decrypt(team_password1)

      expect(account3.cleartext_username).to eq('test')
      expect(account3.cleartext_password).to eq('password')

      expect do
        account1.username
        account1.password
      end.to raise_error(ActiveModel::MissingAttributeError)
    end

  end

  context 'down' do
    before { migration.up }

    it 'reverts to previous schema' do

      migration.down

      account1 = Account.first
      expect(account1.password).to
      expect(account1.password).to
    end
  end

  private

end
