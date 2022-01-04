# frozen_string_literal: true

require 'spec_helper'

describe EncryptedData do

  let(:json) { "{\"password\":{\"iv\":\"a2V5\\n\",\"data\":\"#{blob_b64}\"}}" }
  let(:encrypted_data) { EncryptedData.load(json) }
  let(:blob) { SecureRandom.random_bytes(2) }
  let(:blob_b64) { Base64.strict_encode64(blob) }

  it 'stores values as base64' do
    expect(encrypted_data[:password]).to eq(iv: 'key', data: blob)

    new_blob = SecureRandom.random_bytes(2)
    encrypted_data[:password] = { iv: nil, data: new_blob }

    json_dump = JSON.parse(EncryptedData.dump(encrypted_data))

    new_blob_b64 = Base64.strict_encode64(new_blob)
    expect(json_dump).to eq('password' => { 'data' => new_blob_b64, 'iv' => nil })
  end

  it 'can be initialized with empty data' do
    [nil, '', '  '].each do |e|
      encrypted_data = EncryptedData.load(e)

      new_blob = SecureRandom.random_bytes(2)
      encrypted_data[:username] = { iv: nil, data: new_blob }
      encrypted_data[:password] = { iv: nil, data: new_blob }

      json_dump = JSON.parse(EncryptedData.dump(encrypted_data))

      new_blob_b64 = Base64.strict_encode64(new_blob)
      expect(json_dump).to eq('password' => { 'data' => new_blob_b64, 'iv' => nil },
                              'username' => { 'data' => new_blob_b64, 'iv' => nil })
    end
  end

  it 'rejects entries with blank data' do
    encrypted_data[:password] = { iv: 'iv', data: '' }

    expect(EncryptedData.dump(encrypted_data)).to eq('{}')
  end

  it 'returns nil for non existing key' do
    expect(encrypted_data[:fantasy]).to eq(nil)
  end
end
