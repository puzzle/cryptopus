# frozen_string_literal: true

require 'rails_helper'

describe Authentication::UserAuthenticator::Totp do
  subject do
    described_class.new(totp_code: @code,
                        session: bobs_session)
  end

  let(:bobs_session) { { two_factor_authentication_user_id: bob.id } }
  let(:bob) { users(:bob) }
  let(:bobs_totp_authenticator) do
    described_class.new(session: bobs_session).send(:otp).send(:authenticator)
  end

  it 'authenticates bob code' do
    @code = bobs_totp_authenticator.now

    expect(subject.authenticate!).to eq true
  end

  it 'fails authentication if code blank' do
    @code = ''

    expect(subject.authenticate!).to be false
  end

  it 'fails authentication if wrong code' do
    @code = bobs_totp_authenticator.now + '1'

    expect(subject.authenticate!).to be false
  end

  it 'fails authentication if code includes special characters' do
    @code = '111111?'

    expect(subject.authenticate!).to be false
  end

  it 'fails authentication if required params missing' do
    expect(subject.authenticate!).to be false
  end

  it 'fails authentication if user is locked' do
    bob.update!(locked: true)

    @code = bobs_totp_authenticator.now

    expect(subject.authenticate!).to be false
  end
end
