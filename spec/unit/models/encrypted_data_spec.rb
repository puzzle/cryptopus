# frozen_string_literal: true

require 'spec_helper'

describe EncryptedData do

  let(:json) { "{\"password\":{\"iv\":\"#{b64(iv_blob)}\",\"data\":\"#{b64(data_blob)}\"}}" }
  let(:encrypted_data) { EncryptedData.load(json) }
  let(:data_blob) { new_blob }
  let(:iv_blob) { new_blob }

  it 'stores values as base64' do
    expect(encrypted_data[:password]).to eq(iv: iv_blob, data: data_blob)

    new_blob = SecureRandom.random_bytes(2)
    encrypted_data[:password] = { iv: nil, data: new_blob }

    json_dump = JSON.parse(EncryptedData.dump(encrypted_data))

    expect(json_dump).to eq('password' => { 'data' => b64(new_blob), 'iv' => nil })
  end

  it 'can be initialized with empty data' do
    [nil, '', '  '].each do |e|
      encrypted_data = EncryptedData.load(e)

      new_blob = SecureRandom.random_bytes(2)
      encrypted_data[:username] = { iv: nil, data: new_blob }
      encrypted_data[:password] = { iv: nil, data: new_blob }

      json_dump = JSON.parse(EncryptedData.dump(encrypted_data))

      expect(json_dump).to eq('password' => { 'data' => b64(new_blob), 'iv' => nil },
                              'username' => { 'data' => b64(new_blob), 'iv' => nil })
    end
  end

  it 'rejects entries with blank data' do
    encrypted_data[:password] = { iv: iv_blob, data: nil }

    expect(EncryptedData.dump(encrypted_data)).to eq('{}')
  end

  it 'returns nil for non existing key' do
    expect(encrypted_data[:fantasy]).to eq(nil)
  end

  private

  def new_blob
    SecureRandom.random_bytes(2)
  end

  def b64(value)
    Base64.strict_encode64(value)
  end
end
