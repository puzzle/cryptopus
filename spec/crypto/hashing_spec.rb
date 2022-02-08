# frozen_string_literal: true

require 'spec_helper'

describe Hashing do
  let(:password) { 'foo password' }

  it 'should create SHA512 password hash' do
    hash = Hashing.hash(password)
    expect(hash).to match(/^sha512\$.*\$.*/)
  end
end