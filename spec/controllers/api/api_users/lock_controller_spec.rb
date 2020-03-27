# frozen_string_literal: true

require 'rails_helper'

describe Api::ApiUsers::LockController do
  include ControllerHelpers

  before(:each) do
    login_as(:bob)
  end

  let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }
  let!(:foreign_api_user) { users(:alice).api_users.create! }

  context 'POST create' do
    context '#lock' do
      it 'locks his api user as user' do
        post :create, params: { id: api_user.id }, xhr: true

        api_user.reload

        expect(api_user).to be_locked
      end

      it 'cannot lock a foreign api user as user' do
        foreign_api_user.update!(valid_until: Time.zone.tomorrow)

        expect(foreign_api_user).to_not be_locked

        post :create, params: { id: foreign_api_user.id }, xhr: true

        foreign_api_user.reload

        expect(foreign_api_user).to_not be_locked
      end
    end
  end

  context 'DELETE destroy' do
    context '#unlock' do
      it 'unlocks his api user as user' do
        api_user.update!(locked: true)

        delete :destroy, params: { id: api_user.id }, xhr: true

        api_user.reload

        api_user.valid_until = Time.zone.tomorrow
        expect(api_user).to_not be_locked
      end

      it 'cannot unlock a foreign api user as user' do
        foreign_api_user.update!(locked: true)

        delete :destroy, params: { id: foreign_api_user.id }, xhr: true

        foreign_api_user.reload

        expect(foreign_api_user).to be_locked
      end
    end
  end
end
