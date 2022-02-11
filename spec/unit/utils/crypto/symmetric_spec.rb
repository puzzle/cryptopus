# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../app/utils/crypto/symmetric'

describe Crypto::Symmetric do

  it 'raises implement encrypt in subclass' do
    expect do
      described_class.encrypt
    end.to raise_error('Implement in subclass')
  end

  it 'raises implement decrypt in subclass' do
    expect do
      described_class.decrypt
    end.to raise_error('Implement in subclass')
  end

  it 'raises implement random_key in subclass' do
    expect do
      described_class.random_key
    end.to raise_error('Implement in subclass')
  end
end