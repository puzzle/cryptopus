# frozen_string_literal: true

require 'spec_helper'

describe Api::Admin::UsersController do
  include ControllerHelpers

  context 'GET index' do
    let(:bob) { users(:bob) }
    let(:attributes) { %w[username label last_login_at last_login_from provider_uid role auth] }

    context 'as user' do
      before { login_as(:alice) }

      it 'returns no users' do
        get :index, xhr: true

        expect(response).to have_http_status(403)

        expect(data).to be_nil
      end
    end

    context 'as conf admin' do
      before do
        login_as(:tux)
        bob.lock!

        expect(bob).to be_locked
      end

      it 'returns unlocked users without locked param' do
        get :index, xhr: true

        ids = data.map { |user| user['id'].to_i }
        labels = data.map { |user| user['attributes']['label'] }

        expect(data.size).to eq(4)

        user1_json_attributes = data.first['attributes']

        expect_json_object_includes_keys(user1_json_attributes, attributes)

        User::Human.unlocked.each do |user|
          expect(ids).to include(user.id)
          expect(labels).to include(user.label)
        end
      end

      it 'returns unlocked users with locked param as false' do
        get :index, params: { locked: 'false' }, xhr: true

        ids = data.map { |user| user['id'].to_i }
        labels = data.map { |user| user['attributes']['label'] }

        expect(data.size).to eq(4)

        user1_json_attributes = data.first['attributes']

        expect_json_object_includes_keys(user1_json_attributes, attributes)

        User::Human.unlocked.each do |user|
          expect(ids).to include(user.id)
          expect(labels).to include(user.label)
        end
      end

      it 'returns locked users with locked param as true' do
        get :index, params: { locked: 'true' }, xhr: true

        ids = data.map { |user| user['id'].to_i }
        labels = data.map { |user| user['attributes']['label'] }

        expect(data.size).to eq(1)

        user1_json_attributes = data.first['attributes']

        expect_json_object_includes_keys(user1_json_attributes, attributes)

        User::Human.locked.each do |user|
          expect(ids).to include(user.id)
          expect(labels).to include(user.label)
        end
      end
    end

    context 'as admin' do
      before do
        login_as(:admin)
        bob.lock!

        expect(bob).to be_locked
      end

      it 'returns unlocked users without locked param' do
        get :index, xhr: true

        ids = data.map { |user| user['id'].to_i }
        labels = data.map { |user| user['attributes']['label'] }

        expect(data.size).to eq(4)

        user1_json_attributes = data.first['attributes']

        expect_json_object_includes_keys(user1_json_attributes, attributes)

        User::Human.unlocked.each do |user|
          expect(ids).to include(user.id)
          expect(labels).to include(user.label)
        end
      end

      it 'returns unlocked users with locked param as false' do
        get :index, params: { locked: 'false' }, xhr: true

        ids = data.map { |user| user['id'].to_i }
        labels = data.map { |user| user['attributes']['label'] }

        expect(data.size).to eq(4)

        user1_json_attributes = data.first['attributes']

        expect_json_object_includes_keys(user1_json_attributes, attributes)

        User::Human.unlocked.each do |user|
          expect(ids).to include(user.id)
          expect(labels).to include(user.label)
        end
      end

      it 'returns locked users with locked param as true' do
        get :index, params: { locked: 'true' }, xhr: true

        ids = data.map { |user| user['id'].to_i }
        labels = data.map { |user| user['attributes']['label'] }

        expect(data.size).to eq(1)

        user1_json_attributes = data.first['attributes']

        expect_json_object_includes_keys(user1_json_attributes, attributes)

        User::Human.locked.each do |user|
          expect(ids).to include(user.id)
          expect(labels).to include(user.label)
        end
      end
    end
  end

  context 'DELETE destroy' do
    it 'cannot delete own user as logged-in admin user' do
      bob = users(:bob)
      bob.update!(role: 2)
      login_as(:bob)

      expect do
        delete :destroy, params: { id: bob.id }
      end.to change { User.count }.by(0)

      expect(bob.reload).to be_persisted
      expect(errors).to eq(['flashes.admin.admin.no_access'])
    end

    it 'cannot delete another user as non admin' do
      alice = users(:alice)
      login_as(:bob)

      expect do
        delete :destroy, params: { id: alice.id }
      end.to change { User.count }.by(0)

      expect(alice.reload).to be_persisted
      expect(errors).to eq(['flashes.admin.admin.no_access'])
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
end
