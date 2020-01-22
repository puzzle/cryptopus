require "test_helper"

class Api::Admin::Users::RoleControllerTest < ActionController::TestCase

   include ControllerTest::DefaultHelper

   setup do
     GeoIp.stubs(:activated?)
   end

   context '#update' do
    context 'root' do
      test 'root updates admin to user' do
        teammembers(:team1_bob).destroy!
        admin = users(:admin)

        login_as(:root)
        patch :update, params: { id: admin.id, role: :user }, xhr: true
        admin.reload

        assert_not admin.admin?
        assert_not admin.teammembers.find_by(team_id: teams(:team1))
      end
    end

    context 'admin' do
      test 'admin updates user to conf admin' do
        teammembers(:team1_bob).destroy!
        bob = users(:bob)

        login_as(:admin)
        patch :update, params: { id: bob, role: :conf_admin }, xhr: true

        bob.reload
        assert_equal true, bob.conf_admin?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end

      test 'admin updates user to admin' do
        teammembers(:team1_bob).destroy!
        bob = users(:bob)

        login_as(:admin)
        patch :update, params: { id: bob, role: :admin }, xhr: true

        bob.reload
        assert_equal true, bob.admin?
        assert_equal true, teams(:team1).teammember?(bob)
      end
      
      test 'admin updates conf_admin to admin' do
        teammembers(:team1_bob).destroy!
        conf_admin = users(:conf_admin)

        login_as(:admin)
        patch :update, params: { id: conf_admin, role: :admin }, xhr: true

        conf_admin.reload
        assert_equal true, conf_admin.admin?
        assert_equal true, teams(:team1).teammember?(conf_admin)
      end

      test 'admin updates admin to conf_admin' do
        teammembers(:team1_bob).destroy!
        admin2 = Fabricate(:admin)

        login_as(:admin)
        patch :update, params: { id: admin2, role: :conf_admin }, xhr: true

        admin2.reload
        assert_equal true, admin2.conf_admin?
        assert_equal false, teams(:team1).teammember?(admin2)
      end
      
      test 'admin updates admin to user' do
        teammembers(:team1_bob).destroy!
        admin2 = Fabricate(:admin)

        login_as(:admin)
        patch :update, params: { id: admin2, role: :user }, xhr: true

        admin2.reload
        assert_equal true, admin2.user?
        assert_equal false, teams(:team1).teammember?(admin2)
      end
      
      test 'admin updates conf_admin to user' do
        teammembers(:team1_bob).destroy!
        conf_admin = users(:conf_admin)

        login_as(:admin)
        patch :update, params: { id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        assert_equal true, conf_admin.user?
        assert_equal false, teams(:team1).teammember?(conf_admin)
      end
      
      test 'admin cannot update himself' do
        teammembers(:team1_bob).destroy!
        admin = users(:admin)

        login_as(:admin)
        patch :update, params: { id: admin, role: :conf_admin }, xhr: true

        admin.reload
        assert_equal true, admin.admin?
        assert_equal true, teams(:team1).teammember?(admin)
      end
    end
    
    context 'conf_admin' do
      test 'conf admin updates user to conf admin' do
        teammembers(:team1_bob).destroy!
        bob = users(:bob)

        login_as(:tux)
        patch :update, params: { id: bob, role: :conf_admin }, xhr: true

        bob.reload
        assert_equal true, bob.conf_admin?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end

      test 'conf admin cannot update user to admin' do
        teammembers(:team1_bob).destroy!
        bob = users(:bob)

        login_as(:tux)
        assert_raises ArgumentError do
          patch :update, params: { id: bob, role: :admin }, xhr: true
        end
      end
      
      test 'conf admin updates conf admin to user' do
        teammembers(:team1_bob).destroy!
        conf_admin2 = Fabricate(:conf_admin)

        login_as(:tux)
        patch :update, params: { id: conf_admin2, role: :user }, xhr: true

        conf_admin2.reload
        assert_equal true, conf_admin2.user?
        assert_not conf_admin2.teammembers.find_by(team_id: teams(:team1))
      end

      test 'conf admin cannot update conf admin to admin' do
        teammembers(:team1_bob).destroy!
        conf_admin2 = Fabricate(:conf_admin) 

        login_as(:tux)
        assert_raises ArgumentError do
          patch :update, params: { id: conf_admin2, role: :admin }, xhr: true
        end
      end
      
      test 'conf admin cannot update admin to conf admin' do
        teammembers(:team1_bob).destroy!
        admin = users(:admin)

        login_as(:tux)
        patch :update, params: { id: admin, role: :conf_admin }, xhr: true

        admin.reload
        assert_equal true, admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'conf admin cannot update admin to user' do
        teammembers(:team1_bob).destroy!
        admin = users(:admin)

        login_as(:tux)
        patch :update, params: { id: admin, role: :user }, xhr: true

        admin.reload
        assert_equal true, admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'conf admin cannot update himself' do
        teammembers(:team1_bob).destroy!
        conf_admin = users(:conf_admin)

        login_as(:tux)
        patch :update, params: { id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        assert_equal true, conf_admin.conf_admin?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end
    end
    
    context 'user' do
      test 'user cannot update admin to conf admin' do
        teammembers(:team1_bob).destroy!
        admin = users(:admin)

        login_as(:bob)
        patch :update, params: { id: admin, role: :conf_admin }, xhr: true

        admin.reload
        assert_equal true, admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end

      test 'user cannot update admin to user' do
        teammembers(:team1_bob).destroy!
        admin = users(:admin)

        login_as(:bob)
        patch :update, params: { id: admin, role: :user }, xhr: true

        admin.reload
        assert_equal true, admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'user cannot update conf admin to admin' do
        teammembers(:team1_bob).destroy!
        conf_admin = users(:conf_admin)

        login_as(:bob)
        patch :update, params: { id: conf_admin, role: :admin }, xhr: true

        conf_admin.reload
        assert_equal true, conf_admin.conf_admin?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end

      test 'user cannot update conf admin to user' do
        teammembers(:team1_bob).destroy!
        conf_admin = users(:conf_admin)

        login_as(:bob)
        patch :update, params: { id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        assert_equal true, conf_admin.conf_admin?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'user cannot update user to conf admin' do
        teammembers(:team1_alice).destroy!
        alice = users(:alice)

        login_as(:bob)
        patch :update, params: { id: alice, role: :conf_admin }, xhr: true

        alice.reload
        assert_equal true, alice.user?
        assert_not alice.teammembers.find_by(team_id: teams(:team1))
      end

      test 'user cannot update user to admin' do
        teammembers(:team1_alice).destroy!
        alice = users(:alice)

        login_as(:bob)
        patch :update, params: { id: alice, role: :admin }, xhr: true

        alice.reload
        assert_equal true, alice.user?
        assert_not alice.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'user cannot update himself' do
        teammembers(:team1_bob).destroy!
        bob = users(:bob)

        login_as(:bob)
        patch :update, params: { id: bob, role: :conf_admin }, xhr: true

        bob.reload
        assert_equal true, bob.user?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end
    end
  end
end
