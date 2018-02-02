# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#update_role' do
    context 'root' do
      test 'root updates admin to user' do
        teammembers(:team1_bob).destroy
        admin = users(:admin)

        login_as(:root)
        patch :update_role, params: { user_id: admin, role: :user }, xhr: true
        admin.reload

        assert_not admin.admin?
        assert_not admin.teammembers.find_by(team_id: teams(:team1))
      end
    end

    context 'admin' do
      test 'admin updates user to conf admin' do
        teammembers(:team1_bob).destroy
        bob = users(:bob)

        login_as(:admin)
        patch :update_role, params: { user_id: bob, role: :conf_admin }, xhr: true

        bob.reload
        assert bob.conf_admin?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end

      test 'admin updates user to admin' do
        teammembers(:team1_bob).destroy
        bob = users(:bob)

        login_as(:admin)
        patch :update_role, params: { user_id: bob, role: :admin }, xhr: true

        bob.reload
        assert bob.admin?
        assert bob.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'admin updates conf_admin to admin' do
        teammembers(:team1_bob).destroy
        conf_admin = users(:conf_admin)

        login_as(:admin)
        patch :update_role, params: { user_id: conf_admin, role: :admin }, xhr: true

        conf_admin.reload
        assert conf_admin.admin?
        assert conf_admin.teammembers.find_by(team_id: teams(:team1))
      end

      test 'admin updates admin to conf_admin' do
        teammembers(:team1_bob).destroy
        admin2 = Fabricate(:admin)

        login_as(:admin)
        patch :update_role, params: { user_id: admin2, role: :conf_admin }, xhr: true

        admin2.reload
        assert admin2.conf_admin?
        assert_not admin2.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'admin updates admin to user' do
        teammembers(:team1_bob).destroy
        admin2 = Fabricate(:admin)

        login_as(:admin)
        patch :update_role, params: { user_id: admin2, role: :user }, xhr: true

        admin2.reload
        assert admin2.user?
        assert_not admin2.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'admin updates conf_admin to user' do
        teammembers(:team1_bob).destroy
        conf_admin = users(:conf_admin)

        login_as(:admin)
        patch :update_role, params: { user_id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        assert conf_admin.user?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'admin cannot update himself' do
        teammembers(:team1_bob).destroy
        admin = users(:admin)

        login_as(:admin)
        patch :update_role, params: { user_id: admin, role: :conf_user }, xhr: true

        admin.reload
        assert admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
    end
    
    context 'conf_admin' do
      test 'conf admin updates user to conf admin' do
        teammembers(:team1_bob).destroy
        bob = users(:bob)

        login_as(:tux)
        patch :update_role, params: { user_id: bob, role: :conf_admin }, xhr: true

        bob.reload
        assert bob.conf_admin?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end

      test 'conf admin cannot update user to admin' do
        teammembers(:team1_bob).destroy
        bob = users(:bob)

        login_as(:tux)
        patch :update_role, params: { user_id: bob, role: :admin }, xhr: true

        bob.reload
        assert bob.user?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'conf admin updates conf admin to user' do
        teammembers(:team1_bob).destroy
        conf_admin2 = Fabricate(:conf_admin)

        login_as(:tux)
        patch :update_role, params: { user_id: conf_admin2, role: :user }, xhr: true

        conf_admin2.reload
        assert conf_admin2.user?
        assert_not conf_admin2.teammembers.find_by(team_id: teams(:team1))
      end

      test 'conf admin cannot update conf admin to admin' do
        teammembers(:team1_bob).destroy
        conf_admin2 = Fabricate(:conf_admin) 

        login_as(:tux)
        patch :update_role, params: { user_id: conf_admin2, role: :admin }, xhr: true

        conf_admin2.reload
        assert conf_admin2.conf_admin?
        assert_not conf_admin2.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'conf admin cannot update admin to conf admin' do
        teammembers(:team1_bob).destroy
        admin = users(:admin)

        login_as(:tux)
        patch :update_role, params: { user_id: admin, role: :conf_admin }, xhr: true

        admin.reload
        assert admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'conf admin cannot update admin to user' do
        teammembers(:team1_bob).destroy
        admin = users(:admin)

        login_as(:tux)
        patch :update_role, params: { user_id: admin, role: :user }, xhr: true

        admin.reload
        assert admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'conf admin cannot update himself' do
        teammembers(:team1_bob).destroy
        conf_admin = users(:conf_admin)

        login_as(:tux)
        patch :update_role, params: { user_id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        assert conf_admin.conf_admin?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end
    end
    
    context 'user' do
      test 'user cannot update admin to conf admin' do
        teammembers(:team1_bob).destroy
        admin = users(:admin)

        login_as(:bob)
        patch :update_role, params: { user_id: admin, role: :conf_admin }, xhr: true

        admin.reload
        assert admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end

      test 'user cannot update admin to user' do
        teammembers(:team1_bob).destroy
        admin = users(:admin)

        login_as(:bob)
        patch :update_role, params: { user_id: admin, role: :user }, xhr: true

        admin.reload
        assert admin.admin?
        assert admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'user cannot update conf admin to admin' do
        teammembers(:team1_bob).destroy
        conf_admin = users(:conf_admin)

        login_as(:bob)
        patch :update_role, params: { user_id: conf_admin, role: :admin }, xhr: true

        conf_admin.reload
        assert conf_admin.conf_admin?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end

      test 'user cannot update conf admin to user' do
        teammembers(:team1_bob).destroy
        conf_admin = users(:conf_admin)

        login_as(:bob)
        patch :update_role, params: { user_id: conf_admin, role: :user }, xhr: true

        conf_admin.reload
        assert conf_admin.conf_admin?
        assert_not conf_admin.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'user cannot update user to conf admin' do
        teammembers(:team1_alice).destroy
        alice = users(:alice)

        login_as(:bob)
        patch :update_role, params: { user_id: alice, role: :conf_admin }, xhr: true

        alice.reload
        assert alice.user?
        assert_not alice.teammembers.find_by(team_id: teams(:team1))
      end

      test 'user cannot update user to admin' do
        teammembers(:team1_alice).destroy
        alice = users(:alice)

        login_as(:bob)
        patch :update_role, params: { user_id: alice, role: :admin }, xhr: true

        alice.reload
        assert alice.user?
        assert_not alice.teammembers.find_by(team_id: teams(:team1))
      end
      
      test 'user cannot update himself' do
        teammembers(:team1_bob).destroy
        bob = users(:bob)

        login_as(:bob)
        patch :update_role, params: { user_id: bob, role: :conf_admin }, xhr: true

        bob.reload
        assert bob.user?
        assert_not bob.teammembers.find_by(team_id: teams(:team1))
      end
    end
  end
 
  context '#destroy' do
    test 'logged-in admin user cannot delete own user' do
      bob = users(:bob)
      bob.update_attribute(:role, 2)
      login_as(:bob)
  
      delete :destroy, params: { id: bob.id }
  
      assert bob.reload.persisted?
      assert_includes(errors, 'You can\'t delete your-self')
    end
  
    test 'non admin cannot delete another user' do
      alice = users(:alice)
      login_as(:bob)
  
      delete :destroy, params: { id: alice.id }
  
      assert alice.reload.persisted?
      assert_includes(errors, 'Access denied')
      assert_equal 403, status_code
    end
  
    test 'admin can delete another user' do
      bob = users(:bob)
      alice = users(:alice)
      bob.update_attribute(:role, :admin)
      login_as(:bob)
  
      delete :destroy, params: { id: alice.id }
  
      assert_not User.find_by(username: 'alice')
    end
  end

  private

  def errors
    JSON.parse(response.body)['messages']['errors']
  end

  def status_code
    JSON.parse(response.code)
  end
end
