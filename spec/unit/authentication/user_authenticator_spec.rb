# frozen_string_literal: true

require 'rails_helper'

describe Authentication::UserAuthenticator do

  it 'returns false by default' do
    expect(authenticator.authenticate!).to be false
  end

  it 'raises implement in subclass' do
    expect do
      error = authenticator.find_or_create_user
      expect(error.message).to eq('implement in subclass')
    end.to raise_error(NotImplementedError)
  end

  it 'raises implement in subclass' do
    expect(authenticator.login_path).to eq(session_new_path)
  end

  private

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator.new(
      username: @username, password: @password
    )
  end

  def api_user
    @api_user ||= bob.api_users.create
  end

  def bob
    users(:bob)
  end

  def private_key
    bob.decrypt_private_key('password')
  end
end
