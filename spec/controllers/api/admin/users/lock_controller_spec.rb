# frozen_string_literal: true

require 'spec_helper'

describe Api::Admin::Users::LockController do
  include ControllerHelpers

  context 'DELETE destroy' do
    allowed_users = [:root, :admin, :tux]
    test_users = [:bob, :conf_admin, :admin]

    allowed_users.each do |actor|
      context "as #{actor}" do
        before { login_as(actor) }

        test_users.each do |user|
          subject { users(user) }

          it "unlocks #{user}" do
            subject.lock!
            expect(subject).to be_locked

            delete :destroy, params: { id: subject.id }, xhr: true
            subject.reload

            expect(subject).to_not be_locked
          end
        end

        let(:api_user) { users(:bob).api_users.create!(description: 'my sweet api user') }

        it 'is unable to unlock api user' do
          api_user.lock!

          expect(api_user).to be_locked

          delete :destroy, params: { id: api_user.id }, xhr: true
          api_user.reload

          expect(response).to have_http_status(404)
          expect(api_user).to be_locked
        end
      end
    end

    context 'as user' do
      before { login_as(:bob) }

      test_users.each do |user|
        subject { users(user) }

        it "does not unlock #{user}" do
          subject.lock!
          expect(subject).to be_locked

          delete :destroy, params: { id: subject.id }, xhr: true

          expect(response).to have_http_status(403)

          subject.reload

          expect(subject).to be_locked
        end
      end
    end
  end
end
