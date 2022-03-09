# frozen_string_literal: true

require 'spec_helper'

describe EncryptableSerializer do
  it 'serializes encryptable to json' do
    credential = encryptables(:credentials1)
    credential.cleartext_username = 'username'
    credential.cleartext_password = 'password'

    as_json = JSON.parse(described_class.new(credential).to_json)

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
