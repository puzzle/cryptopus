# frozen_string_literal: true

require 'rails_helper'

describe Admin::UsersController do
  include ControllerHelpers

  context 'GET index' do
    it 'receives userlist as admin' do
      login_as(:admin)
      get :index

      users = assigns(:users)

      expect(users.size).to eq 5
      expect(users.count).to eq(User::Human.all.count)
      expect(users.any? { |t| t.username == 'root' }).to eq true
    end

    it 'receives userlist as conf admin' do
      login_as(:tux)
      get :index

      users = assigns(:users)

      expect(users.size).to eq 5
      expect(users.any? { |t| t.username == 'root' }).to eq true
    end

    it 'receives userlist as root' do
      login_as(:root)
      get :index

      users = assigns(:users)

      expect(users.size).to eq 5
      expect(users.any? { |t| t.username == 'root' }).to eq true
    end

    it 'does not list locked users' do
      users(:bob).update!(locked: true)

      login_as(:admin)
      get :index

      users = assigns(:users)

      expect(users.size).to eq 4
    end

    it 'does not list locked users as root' do
      users(:bob).update!(locked: true)

      login_as(:root)
      get :index

      users = assigns(:users)

      expect(users.size).to eq 4
    end

    it 'does not receive userlist as user' do
      login_as(:bob)
      get :index

      expect(assigns(:users)).to be_nil
    end
  end

  context 'GET unlock' do
    it 'unlocks user as admin' do
      bob = users(:bob)
      bob.update!(locked: true)
      bob.update!(failed_login_attempts: 5)

      login_as(:admin)
      get :unlock, params: { id: bob.id }

      expect(bob.reload.locked).to eq false
      expect(bob.failed_login_attempts).to eq 0
    end

    it 'unlocks user as conf-admin' do
      bob = users(:bob)
      bob.update!(locked: true)
      bob.update!(failed_login_attempts: 5)

      login_as(:tux)
      get :unlock, params: { id: bob.id }

      expect(bob.reload.locked).to eq false
      expect(bob.failed_login_attempts).to eq 0
    end

    it 'cannot unlock user as normal user' do
      bob = users(:bob)
      bob.update!(locked: true)
      bob.update!(failed_login_attempts: 5)

      login_as(:alice)
      get :unlock, params: { id: bob.id }

      expect(bob.reload.locked).to be true
      expect(bob.failed_login_attempts).to eq 5
    end
  end

  context 'POST update' do
    describe 'admin' do
      it 'updates users attributes as admin' do
        alice = users(:alice)

        login_as(:admin)
        post :update, params: { id: alice, user_human: update_params }

        alice.reload

        expect(alice.username).to eq 'new_username'
        expect(alice.givenname).to eq 'new_givenname'
        expect(alice.surname).to eq 'new_surname'
      end

      it 'updates conf admins attributes as admin' do
        tux = users(:conf_admin)

        login_as(:admin)
        post :update, params: { id: tux, user_human: update_params }

        tux.reload

        expect(tux.username).to eq 'new_username'
        expect(tux.username).to eq 'new_username'
        expect(tux.givenname).to eq 'new_givenname'
      end

      it 'updates admins attributes as admin' do
        admin2 = Fabricate(:admin)

        login_as(:admin)
        post :update, params: { id: admin2, user_human: update_params }

        admin2.reload

        expect(admin2.username).to eq 'new_username'
        expect(admin2.username).to eq 'new_username'
        expect(admin2.givenname).to eq 'new_givenname'
      end

      it 'cannot update ldap-users attributes as admin' do
        bob = users(:bob)
        bob.update!(auth: 'ldap')

        login_as(:admin)
        post :update, params: { id: bob, user_human: update_params }

        bob.reload

        expect(bob.username).to_not be('new_username')
        expect(bob.givenname).to_not be('new_givenname')
        expect(bob.surname).to_not be('new_surname')
        expect(flash[:error]).to match(/Ldap user cannot be updated/)
      end

      it 'cannot update roots attributes as admin' do
        root = users(:root)

        login_as(:admin)
        post :update, params: { id: root, user_human: update_params }

        root.reload

        expect(root.username).to eq 'root'
        expect(root.givenname).to eq 'Root'
        expect(root.surname).to eq 'test'
        expect(flash[:error]).to match(/Access denied/)
      end
    end

    describe 'conf admin' do
      it 'can only update users surname and givenname as conf admin ' do
        alice = users(:alice)

        login_as(:tux)
        post :update, params: { id: alice, user_human: update_params }

        alice.reload

        expect(alice.username).to eq 'alice'
        expect(alice.givenname).to eq 'new_givenname'
        expect(alice.surname).to eq 'new_surname'
      end

      it 'cannot update conf admins attributes as conf admin' do
        conf_admin = Fabricate(:conf_admin)
        tux = users(:conf_admin)

        login_as(conf_admin.username)
        post :update, params: { id: tux, user_human: update_params }

        tux.reload

        expect(tux.username).to eq 'tux'
        expect(tux.givenname).to eq 'Tux'
        expect(tux.surname).to eq 'Miller'
        expect(flash[:error]).to match(/Access denied/)
      end

      it 'cannot update admins attributes as conf admin' do
        admin = users(:admin)

        login_as(:tux)
        post :update, params: { id: admin, user_human: update_params }

        admin.reload

        expect(admin.username).to eq 'admin'
        expect(admin.givenname).to eq 'Admin'
        expect(admin.surname).to eq 'test'
        expect(flash[:error]).to match(/Access denied/)
      end

      it 'cannot update ldap-users attributes as conf admin' do
        bob = users(:bob)
        bob.update!(auth: 'ldap')

        login_as(:tux)
        post :update, params: { id: bob, user_human: update_params }

        bob.reload

        expect(bob.username).to_not be('new_username')
        expect(bob.givenname).to_not be('new_givenname')
        expect(bob.surname).to_not be('new_surname')
        expect(flash[:error]).to match(/Ldap user cannot be updated/)
      end

      it 'cannot update roots attributes as conf admin' do
        root = users(:root)

        login_as(:tux)
        post :update, params: { id: root, user_human: update_params }

        root.reload

        expect(root.username).to eq 'root'
        expect(root.givenname).to eq 'Root'
        expect(root.surname).to eq 'test'
        expect(flash[:error]).to match(/Access denied/)
      end
    end

    describe 'user' do

      it 'cannot update user attributes as users' do
        alice = users(:alice)

        alice_username = alice.username

        login_as(:bob)
        post :update, params: { id: alice, user_human: update_params }

        alice.reload

        assert_redirected_to teams_path

        expect(alice.username).to eq alice_username
      end

      it 'cannot update admins attributes as user' do
        admin2 = Fabricate(:admin)

        admin_username = admin2.username

        login_as(:bob)
        post :update, params: { id: admin2, user_human: update_params }

        admin2.reload

        assert_redirected_to teams_path

        expect(admin2.username).to eq admin_username
      end

    end
  end

  private

  def update_params
    { username: 'new_username',
      givenname: 'new_givenname',
      surname: 'new_surname' }
  end
end
