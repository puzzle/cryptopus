require 'test_helper'

class UserPolicyTest < PolicyTest
  context '#index' do
    test 'admin can access admin/users page' do
      assert_permit admin, User, :index?
    end
    
    test 'conf_admin can access admin/users page' do
      assert_permit conf_admin, User, :index?
    end
    
    test 'user cannot access admin/users page' do
      refute_permit bob, User, :index?
    end
  end

  context '#update' do
    test 'update action permissions' do
      users = [admin, conf_admin, bob]
      records = users
      results = [true, true, true, false, true, true, false, false, false]
      test_action_permissions(:update?, users, records, results)
    end

   # test 'admin can update user information' do
   #   assert_permit admin, bob, :update? 
   # end
   # 
   # test 'admin can update admin information' do
   #   assert_permit conf_admin, admin, :update? 
   # end
   # 
   # test 'conf_admin can update user information' do
   #   assert_permit conf_admin, bob, :update? 
   # end
   # 
   # test 'conf_admin cannot update conf_admin information' do
   #   refute_permit conf_admin, conf_admin, :update? 
   # end

   # test 'user cannot update user information' do
   #   refute_permit bob, bob, :update?
   # end
  end

  context '#new' do
    test 'admin can create a new user' do
      assert_permit admin, bob, :new?
    end
    
    test 'conf_admin can create a new user' do
      assert_permit conf_admin, bob, :new?
    end
    
    test 'user cannot create a new user' do
      refute_permit bob, bob, :new?
    end
  end

  context '#create' do
    test 'admin can create a new user with keypair' do
      assert_permit admin, User, :create?
    end
    
    test 'user cannot create a new user with keypair' do
      refute_permit bob, User, :create?
    end
  end

  context '#unlock' do
    test 'admin can unlock an user' do
      assert_permit admin, bob, :unlock?
    end
    
    test 'user cannot unlock an user' do
      refute_permit bob, bob, :unlock?
    end
  end

  context '#update_role' do
    test 'admin can distribute admin rights' do
      assert_permit admin, bob, :update_role?
    end
    
    test 'user cannot distribute admin rights' do
      refute_permit bob, bob, :update_role?
    end
  end

  context '#destroy' do
    test 'admin destroy an user' do
      assert_permit admin, bob, :destroy?
    end
    
    test 'user cannot destroy an user' do
      refute_permit bob, bob, :destroy?
    end
  end

  context '#resetpassword' do
    test 'admin can reset a password' do
      assert_permit admin, bob, :resetpassword?
    end

    test 'non-admin cannot reset a password' do
      refute_permit bob, bob, :resetpassword?      
      refute_permit bob, alice, :resetpassword?      
      refute_permit alice, bob, :resetpassword?      
    end
  end

  context '#scope' do
    test 'admin receives userlist' do
      assert_not_nil Pundit.policy_scope!(admin, User)
    end

    test 'list received contains only valid users' do
      users = Pundit.policy_scope!(admin, User)

      users.each do |user|
        unless user.ldap_uid
          assert_not_equal user.ldap_uid, 0
        end
      end
    end
    
    test 'user cannot read userlist' do
      assert_nil Pundit.policy_scope!(bob, User)
    end
  end
end
