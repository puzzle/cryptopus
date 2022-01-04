# frozen_string_literal: true

#  Copyright (c) 2008-2022, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe EncryptedData do
  let(:json) { "{\"password\":{\"iv\":\"a2V5\\n\",\"data\":\"YXNkZg==\\n\"}}" }

  it 'stores blob value as base64' do
    loaded_data = EncryptedData.load(json)

    expect(loaded_data[:password]).to eq({:iv=>"key", :data=>"asdf"})

    # Set new values into dataset
    loaded_data[:password] = { iv: 'iv', data: 'data' }
    result = JSON.parse(EncryptedData.dump(loaded_data))

    expect(loaded_data[:password]).to eq({:data=>"data", :iv=>"iv"})
    expect(result).to eq({ "password" => { "data" => "ZGF0YQ==\n", "iv" => "aXY=\n" }})
  end

  it 'rejects not present data' do
    loaded_data = EncryptedData.load(json)

    # Set new values into dataset
    loaded_data[:password] = { iv: 'iv', data: '' }

    expect(EncryptedData.dump(loaded_data)).to eq("{}")
  end

  it 'returns nil if non existent key' do
    loaded_data = EncryptedData.load(json)

    # Try to access non existent key
    expect(loaded_data[:name]).to eq(nil)
  end
end
