require 'test_helper'

class OneTimePasswordTest < ActiveSupport::TestCase

  test 'does not verify if no username given' do
    otp = OneTimePassword.new(nil)

    assert_equal false, otp.verify('123456')
  end

  test 'verifies if correct time based token given' do
    otp = OneTimePassword.new('bob')

    valid_token = otp.send(:authenticator).now
    require 'pry'; binding.pry unless $pstop

    assert_equal true, otp.verify(valid_token)
  end

  test 'does not verify if invalid token given' do
    otp = OneTimePassword.new('bob')

    assert_equal false, otp.verify('123456')
  end

end
