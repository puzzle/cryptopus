# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::LockController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let(:private_key) { users(:bob).decrypt_private_key('password') }
  let!(:foreign_api_user) { users(:alice).api_users.create! }

  context 'POST create' do
    context '#lock' do
      it 'locks his api user as user' do
        post :create, params: { id: api_user.id }, xhr: true

        api_user.reload
        @token = api_user.send(:decrypt_token, private_key)
        @username = api_user.username

        expect(api_user).to be_locked
        expect(authenticate!).to be false
      end

      it 'cannot lock a foreign api user' do
        foreign_api_user.update!(valid_until: Time.zone.tomorrow)

        expect(foreign_api_user).to_not be_locked

        post :create, params: { id: foreign_api_user.id }, xhr: true

        foreign_api_user.reload
        @token = api_user.send(:decrypt_token, private_key)
        @username = api_user.username

        expect(foreign_api_user).to_not be_locked
        expect(authenticate!).to be false
      end
    end
  end

  context 'DELETE destroy' do
    context '#unlock' do
      it 'unlocks his api user as user' do
        api_user.update!(locked: true)

        delete :destroy, params: { id: api_user.id }, xhr: true

        api_user.update!(valid_until: Time.zone.tomorrow)
        api_user.reload
        @token = api_user.send(:decrypt_token, private_key)
        @username = api_user.username

        expect(api_user.locked?).to be false
        expect(authenticate!).to be true
      end

      it 'cannot unlock a foreign api user' do
        foreign_api_user.update!(locked: true)

        delete :destroy, params: { id: foreign_api_user.id }, xhr: true

        foreign_api_user.reload

        expect(foreign_api_user).to be_locked
      end
    end
  end

  private

  def authenticate!
    authenticator.authenticate_by_headers!
  end

  def authenticator
    @authenticator ||= Authentication::UserAuthenticator::Db.new(
      username: @username, password: @token
    )
  end
end
