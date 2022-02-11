# frozen_string_literal: true

require 'spec_helper'

describe Hashing do
  let(:password) { 'foo password' }

  it 'creates SHA512 password hash' do
    hash = Hashing.generate_salted(password)
    expect(hash).to match(/^sha512\$.*\$.*/)
  end
end