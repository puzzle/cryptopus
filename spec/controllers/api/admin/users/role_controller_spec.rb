# frozen_string_literal: true

require 'rails_helper'

describe Api::Admin::Users::RoleController do
  include ControllerHelpers

  let(:bob) { users(:bob) }
  let(:admin) { users(:admin) }
  let(:conf_admin) { users(:conf_admin) }
  let(:alice) { users(:alice) }

  context 'PATCH update' do
    context 'as root' do
      it 'updates admin to user' do
        teammembers(:team1_bob).destroy!

        login_as(:root)
        patch :update, params: { id: admin.id, role: :user }, xhr: true
        admin.reload

        expect(admin).to_not be_admin
        expect(admin.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end
    end

    context 'as admin' do
      it 'updates user to conf admin' do
        teammembers(:team1_bob).destroy!

        login_as(:admin)
        patch :update, params: { id: bob, role: :conf_admin }, xhr: true

        bob.reload
        expect(bob).to be_conf_admin
        expect(bob.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'updates user to admin' do
        teammembers(:team1_bob).destroy!

        login_as(:admin)
        patch :update, params: { id: bob, role: :admin }, xhr: true

        bob.reload
        expect(bob).to be_admin
        expect(teams(:team1).teammember?(bob)).to eq true
      end

      it 'updates conf_admin to admin' do
        teammembers(:team1_bob).destroy!

        login_as(:admin)
        patch :update, params: { id: conf_admin, role: :admin }, xhr: true

        conf_admin.reload
        expect(conf_admin).to be_admin
        expect(teams(:team1).teammember?(conf_admin)).to eq true
      end

      it 'updates admin to conf_admin' do
        teammembers(:team1_bob).destroy!
        admin2 = Fabricate(:admin)

        login_as(:admin)
        patch :update, params: { id: admin2, role: :conf_admin }, xhr: true

        admin2.reload
        expect(admin2).to be_conf_admin
        expect(teams(:team1).teammember?(admin2)).to eq false
      end

      it 'updates admin to user' do
        teammembers(:team1_bob).destroy!
        admin2 = Fabricate(:admin)

        login_as(:admin)
        patch :update, params: { id: admin2, role: :user }, xhr: true

        admin2.reload
        expect(admin2).to be_user
        expect(teams(:team1).teammember?(admin2)).to eq false
      end

      it 'updates conf_admin to user' do
        teammembers(:team1_bob).destroy!

        login_as(:admin)
        patch :update, params: { id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        expect(conf_admin).to be_user
        expect(teams(:team1).teammember?(conf_admin)).to eq false
      end

      it 'cannot update himself' do
        teammembers(:team1_bob).destroy!

        login_as(:admin)
        patch :update, params: { id: admin, role: :conf_admin }, xhr: true

        admin.reload
        expect(admin).to be_admin
        expect(teams(:team1).teammember?(admin)).to eq true
      end
    end

    context 'as conf_admin' do
      it 'updates user to conf admin' do
        teammembers(:team1_bob).destroy!

        login_as(:tux)
        patch :update, params: { id: bob, role: :conf_admin }, xhr: true

        bob.reload
        expect(bob).to be_conf_admin
        expect(bob.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'cannot update user to admin' do
        teammembers(:team1_bob).destroy!

        login_as(:tux)
        patch :update, params: { id: bob, role: :admin }, xhr: true

        expect(response).to have_http_status 400
        expect(errors).to eq(['flashes.api.errors.bad_request'])
      end

      it 'updates conf admin to user' do
        teammembers(:team1_bob).destroy!
        conf_admin2 = Fabricate(:conf_admin)

        login_as(:tux)
        patch :update, params: { id: conf_admin2, role: :user }, xhr: true

        conf_admin2.reload
        expect(conf_admin2).to be_user
        expect(conf_admin2.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'cannot update conf admin to admin' do
        teammembers(:team1_bob).destroy!
        conf_admin2 = Fabricate(:conf_admin)

        login_as(:tux)
        patch :update, params: { id: conf_admin2, role: :admin }, xhr: true

        expect(response).to have_http_status 400
        expect(errors).to eq(['flashes.api.errors.bad_request'])
      end

      it 'cannot update admin to conf admin' do
        teammembers(:team1_bob).destroy!

        login_as(:tux)
        patch :update, params: { id: admin, role: :conf_admin }, xhr: true

        admin.reload
        expect(admin).to be_admin
        expect(admin.teammembers.exists?(team_id: teams(:team1))).to eq true
      end

      it 'cannot update admin to user' do
        teammembers(:team1_bob).destroy!

        login_as(:tux)
        patch :update, params: { id: admin, role: :user }, xhr: true

        admin.reload
        expect(admin).to be_admin
        expect(admin.teammembers.exists?(team_id: teams(:team1))).to eq true
      end

      it 'cannot update himself' do
        teammembers(:team1_bob).destroy!

        login_as(:tux)
        patch :update, params: { id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        expect(conf_admin).to be_conf_admin
        expect(conf_admin.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end
    end

    context 'as user' do
      it 'cannot update admin to conf admin' do
        teammembers(:team1_bob).destroy!

        login_as(:bob)
        patch :update, params: { id: admin, role: :conf_admin }, xhr: true

        admin.reload
        expect(admin).to be_admin
        expect(admin.teammembers.exists?(team_id: teams(:team1))).to eq true
      end

      it 'cannot update admin to user' do
        teammembers(:team1_bob).destroy!

        login_as(:bob)
        patch :update, params: { id: admin, role: :user }, xhr: true

        admin.reload
        expect(admin).to be_admin
        expect(admin.teammembers.exists?(team_id: teams(:team1))).to eq true
      end

      it 'cannot update conf admin to admin' do
        teammembers(:team1_bob).destroy!

        login_as(:bob)
        patch :update, params: { id: conf_admin, role: :admin }, xhr: true

        conf_admin.reload
        expect(conf_admin).to be_conf_admin
        expect(conf_admin.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'cannot update conf admin to user' do
        teammembers(:team1_bob).destroy!

        login_as(:bob)
        patch :update, params: { id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        expect(conf_admin).to be_conf_admin
        expect(conf_admin.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'cannot update user to conf admin' do
        teammembers(:team1_alice).destroy!

        login_as(:bob)
        patch :update, params: { id: alice, role: :conf_admin }, xhr: true

        alice.reload
        expect(alice).to be_user
        expect(alice.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'cannot update user to admin' do
        teammembers(:team1_alice).destroy!

        login_as(:bob)
        patch :update, params: { id: alice, role: :admin }, xhr: true

        alice.reload
        expect(alice).to be_user
        expect(alice.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end

      it 'cannot update himself' do
        teammembers(:team1_bob).destroy!

        login_as(:bob)
        patch :update, params: { id: bob, role: :conf_admin }, xhr: true

        bob.reload
        expect(bob).to be_user
        expect(bob.teammembers.find_by(team_id: teams(:team1))).to be_nil
      end
    end
  end
end
