# frozen_string_literal: true

require 'rails_helper'

describe OneTimePassword do
  it 'raises error if username is blank' do
    expect do
      OneTimePassword.new(nil)
    end.to raise_error('username cant be blank')
  end

  it 'verifies if correct time based token given' do
    otp = OneTimePassword.new('bob')

    valid_token = otp.send(:authenticator).now

    expect(otp.verify(valid_token)).to_not be_nil
  end

  it 'does not verify if invalid token given' do
    otp = OneTimePassword.new('bob')

    expect(otp.verify('123456')).to be_nil
  end
end
