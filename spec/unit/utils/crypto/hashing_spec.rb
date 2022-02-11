# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../app/utils/crypto/hashing'

describe Crypto::Hashing do
  let(:password) { 'foo password' }
  let(:salted_password) { 'sha512$518a2016ed1d1d1e4d033a2f7ea374b8$7a3ce4274646e140a77' +
    '32e0e3ebd8b331624bc07d12b5f8c526983ce1c26fdf5ba8e65ca9b5acb2c155f04de5265b0a8d3bf' +
    '3d0494386a38e6b8d66a799e6b9a' }

  it 'creates SHA512 password hash' do
    hash = Crypto::Hashing.generate_salted(password)
    expect(hash).to match(/^sha512\$.*\$.*/)
  end

  it 'matches salted to password to cleartext password' do
    result = Crypto::Hashing.matches?(salted_password, password)
    expect(result).to eq(true)
  end
end