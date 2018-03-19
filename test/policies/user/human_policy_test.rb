require 'test_helper'

class HumanPolicyTest < PolicyTest
  context '#index' do
    test 'admin can access admin/users page' do
      assert_permit admin, User::Human, :index?
    end
    
    test 'conf_admin can access admin/users page' do
      assert_permit conf_admin, User::Human, :index?
    end
    
    test 'user cannot access admin/users page' do
      refute_permit bob, User::Human, :index?
    end
  end

  context '#update' do
    context 'admin' do
      test 'admin can update admin information' do
        assert_permit admin, admin, :update?
      end

      test 'admin can update conf_admin information' do
        assert_permit admin, conf_admin, :update?
      end

      test 'admin can update user information' do
        assert_permit admin, bob, :update?
      end
    end

    context 'conf_admin' do
      test 'conf_admin cannot update admin information' do
        refute_permit conf_admin, admin, :update?
      end

      test 'conf_admin cannot update conf_admin information' do
        refute_permit conf_admin, conf_admin, :update?
      end

      test 'conf_admin can update user information' do
        assert_permit conf_admin, bob, :update?
      end
    end

    context 'user' do
      test 'user cannot update admin information' do
        refute_permit bob, bob, :update?
      end

      test 'user cannot update conf_admin information' do
        refute_permit bob, bob, :update?
      end

      test 'user cannot update user information' do
        refute_permit bob, bob, :update?
      end
    end
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
      assert_permit admin, User::Human, :create?
    end

    test 'conf_admin can create a new user with keypair' do
      assert_permit conf_admin, User::Human, :create?
    end

    test 'user cannot create a new user with keypair' do
      refute_permit bob, User::Human, :create?
    end
  end

  context '#unlock' do
    test 'admin can unlock an user' do
      assert_permit admin, bob, :unlock?
    end

    test 'conf_admin can unlock an user' do
      assert_permit conf_admin, bob, :unlock?
    end

    test 'user cannot unlock an user' do
      refute_permit bob, bob, :unlock?
    end
  end

  context '#update_role' do
    context 'admin' do
      test 'admin cannot update a roots role' do
        refute_permit admin, root, :update_role?
      end

      test 'admin can update a users role' do
        assert_permit admin, bob, :update_role?
      end

      test 'admin can update a conf admins role' do
        assert_permit admin, conf_admin, :update_role?
      end

      test 'admin can update an admins role' do
        assert_permit admin, admin2, :update_role?
      end
      
      test 'admin cannot update himself' do
        refute_permit admin, admin, :update_role?
      end
    end

    context 'conf_admin' do
      test 'conf admin cannot update a roots role' do
        refute_permit conf_admin, root, :update_role?
      end

      test 'conf_admin can update a users role' do
        assert_permit conf_admin, bob, :update_role?
      end

      test 'conf_admin can update a conf admins role' do
        assert_permit conf_admin, conf_admin2, :update_role?
      end

      test 'conf_admin cannot update an admins role' do
        refute_permit conf_admin, admin, :update_role?
      end
      
      test 'conf_admin cannot update himself' do
        refute_permit conf_admin, conf_admin, :update_role?
      end
    end

    context 'user' do
      test 'user cannot update a roots role' do
        refute_permit bob, root, :update_role?
      end

      test 'user cannot update a users role' do
        refute_permit bob, alice, :update_role?
      end

      test 'user cannot update a conf admins role' do
        refute_permit bob, conf_admin, :update_role?
      end

      test 'user cannot update an admins role' do
        refute_permit bob, admin, :update_role?
      end
      
      test 'user cannot update himself' do
        refute_permit bob, bob, :update_role?
      end
    end
  end

  context '#destroy' do
    context 'admin' do
      test 'admin cannot destroy root' do
        refute_permit admin, root, :destroy?
      end

      test 'admin can destroy an admin' do
        assert_permit admin, admin, :destroy?
      end

      test 'admin can destroy a conf_admin' do
        assert_permit admin, conf_admin, :destroy?
      end

      test 'admin can destroy a user' do
        assert_permit admin, bob, :destroy?
      end

      test 'admin can destroy a ldap user' do
        #  LdapConnection.any_instance.expects(:exists?)
        #                             .with('bob')
        #                             .returns(true)

        assert_permit admin, ldap_user, :destroy?
      end

      # test 'admin can destroy a removed ldap user' do
      #   LdapConnection.any_instance.expects(:exists?)
      #                              .with('bob')
      #                              .returns(false)

      #   assert_permit admin, ldap_user, :destroy?
      # end
    end

    context 'conf_admin' do
      test 'conf admin cannot destroy root' do
        refute_permit conf_admin, root, :destroy?
      end

      test 'conf_admin cannot destroy an admin' do
        refute_permit conf_admin, admin, :destroy?
      end

      test 'conf_admin cannot destroy a conf_admin' do
        refute_permit conf_admin, conf_admin, :destroy?
      end

      test 'conf_admin can destroy a user' do
        assert_permit conf_admin, bob, :destroy?
      end

      test 'conf_admin can destroy a ldap user' do
        # LdapConnection.any_instance.expects(:exists?)
        #                            .with('bob')
        #                            .returns(true)

        assert_permit conf_admin, ldap_user, :destroy?
      end

      # test 'conf_admin can destroy a removed ldap user' do
      #   LdapConnection.any_instance.expects(:exists?)
      #                              .with('bob')
      #                              .returns(false)

      #   assert_permit conf_admin, ldap_user, :destroy?
      # end
    end

    context 'user' do
      test 'user cannot destroy root' do
        refute_permit bob, root, :destroy?
      end

      test 'user cannot destroy an admin' do
        refute_permit bob, admin, :destroy?
      end

      test 'user cannot destroy a conf_admin' do
        refute_permit bob, conf_admin, :destroy?
      end

      test 'user cannot destroy a user' do
        refute_permit bob, bob, :destroy?
      end

      test 'user cannot destroy a ldap user' do
        refute_permit bob, ldap_user, :destroy?
      end
    end
  end

  context '#resetpassword' do
    context 'admin' do
      test 'admin can reset conf_admins password' do
        assert_permit admin, conf_admin, :resetpassword?
      end

      test 'admin can reset users password' do
        assert_permit admin, bob, :resetpassword?
      end

      test 'admin cannot reset his own password' do
        refute_permit admin, admin, :resetpassword?
      end
    end

    context 'conf_admin' do
      test 'conf_admin cannot reset admins password' do
        refute_permit conf_admin, admin, :resetpassword?
      end

      test 'conf_admin cannot reset conf_admins password' do
        refute_permit conf_admin, conf_admin, :resetpassword?
      end

      test 'conf_admin can reset users password' do
        assert_permit conf_admin, bob, :resetpassword?
      end
    end

    context 'user' do
      test 'non-admin cannot reset a password' do
        refute_permit bob, bob, :resetpassword?
        refute_permit bob, alice, :resetpassword?
        refute_permit alice, bob, :resetpassword?
        refute_permit bob, admin, :resetpassword?
        refute_permit bob, conf_admin, :resetpassword?
      end
    end
  end

  context '#scope' do
    test 'admin receives userlist' do
      assert_not_nil Pundit.policy_scope!(admin, User::Human)
    end

    test 'conf_admin receives userlist' do
      assert_not_nil Pundit.policy_scope!(conf_admin, User::Human)
    end

    test 'list received contains all users' do
      users = Pundit.policy_scope!(admin, User::Human)

      assert_equal User::Human.all.count, users.count
    end
    
    test 'list received contains only valid users' do
      users = Pundit.policy_scope!(conf_admin, User::Human)

      ldap_uids = users.pluck(:ldap_uid)

      refute_includes ldap_uids, 0
    end

    test 'user cannot read userlist' do
      assert_nil Pundit.policy_scope!(bob, User::Human)
    end
  end

  private

  def conf_admin2
    conf_admin2 = Fabricate(:admin)
    admin2_pk = admin2.decrypt_private_key('password')
    conf_admin2.update_role(conf_admin2, :conf_admin, admin2_pk)
    conf_admin2
  end

  def admin2
    Fabricate(:admin)
  end
end
