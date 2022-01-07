# frozen_string_literal: true

require 'spec_helper'

describe AccountSerializer do
  it 'serializes account to json' do
    account = accounts(:account1)
    account.cleartext_username = 'username'
    account.cleartext_password = 'password'

    as_json = JSON.parse(AccountSerializer.new(account).to_json)

    attrs = %w[name id folder]

    attrs.each do |attr|
      expect(as_json).to include(attr)
    end

    expect(as_json).not_to include 'updated_at'
    expect(as_json).not_to include 'created_at'
    expect(as_json).not_to include 'username'
    expect(as_json).not_to include 'password'
  end
end
