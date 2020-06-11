# frozen_string_literal: true

require 'rails_helper'

describe Authentication::UserAuthenticator do

  it 'raises implement in subclass' do
    expect do
      error = authenticator.authenticate!
      expect(error.message).to eq('implement in subclass')
    end.to raise_error(NotImplementedError)
  end

  it 'raises implement in subclass' do
    expect do
      error = authenticator.find_or_create_user
      expect(error.message).to eq('implement in subclass')
    end.to raise_error(NotImplementedError)
  end

  it 'raises implement in subclass' do
    expect do
      error = authenticator.login_path
      expect(error.message).to eq('implement in subclass')
    end.to raise_error(NotImplementedError)
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
