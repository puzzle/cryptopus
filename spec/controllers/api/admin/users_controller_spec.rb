# frozen_string_literal: true

require 'rails_helper'

describe Api::Admin::UsersController do
  include ControllerHelpers

  context 'DELETE destroy' do
    it 'cannot delete own user as logged-in admin user' do
      bob = users(:bob)
      bob.update!(role: 2)
      login_as(:bob)

      expect do
        delete :destroy, params: { id: bob.id }
      end.to change { User.count }.by(0)

      expect(bob.reload).to be_persisted
      expect(errors).to include('Access denied')
    end

    it 'cannot delete another user as non admin' do
      alice = users(:alice)
      login_as(:bob)

      expect do
        delete :destroy, params: { id: alice.id }
      end.to change { User.count }.by(0)

      expect(alice.reload).to be_persisted
      expect(errors).to include('Access denied')
      expect(response).to have_http_status(403)
    end

    it 'can delete another user as admin' do
      bob = users(:bob)
      alice = users(:alice)
      bob.update!(role: :admin)
      login_as(:bob)

      expect do
        delete :destroy, params: { id: alice.id }
      end.to change { User.count }.by(-1)

      expect(User.find_by(username: 'alice')).to be_nil
    end
  end

  private

  def errors
    json['messages']['errors']
  end
end
