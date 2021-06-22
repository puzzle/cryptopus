# frozen_string_literal: true

require 'spec_helper'

describe User::HumanPolicy do
  include PolicyHelper

  context '#index' do
    it 'lets an admin access admin/users page' do
      assert_permit admin, User::Human, :index?
    end

    it 'lets a conf_admin access admin/users page' do
      assert_permit conf_admin, User::Human, :index?
    end

    it 'lets a user not access admin/users page' do
      refute_permit bob, User::Human, :index?
    end
  end

  context '#update' do
    context 'admin' do
      it 'can update admin information' do
        assert_permit admin, admin, :update?
      end

      it 'can update conf_admin information' do
        assert_permit admin, conf_admin, :update?
      end

      it 'can update user information' do
        assert_permit admin, bob, :update?
      end

      context 'auth provider NOT db' do
        before do
          allow(AuthConfig).to receive(:db_enabled?).and_return(false)
        end
        it 'is NOT possible to update any users' do
          refute_permit root, bob, :update?
          refute_permit bob, bob, :update?
          refute_permit conf_admin, bob, :update?
          refute_permit conf_admin, alice, :update?
          refute_permit admin, alice, :update?
        end
      end

    end

    context 'conf_admin' do
      it 'cannot update admin information' do
        refute_permit conf_admin, admin, :update?
      end

      it 'cannot update conf_admin information' do
        refute_permit conf_admin, conf_admin, :update?
      end

      it 'can update user information' do
        assert_permit conf_admin, bob, :update?
      end

      context 'auth provider NOT db' do
        before do
          allow(AuthConfig).to receive(:db_enabled?).and_return(false)
        end
        it 'is NOT possible to create any users' do
          refute_permit root, bob, :create?
          refute_permit bob, bob, :create?
          refute_permit conf_admin, bob, :create?
          refute_permit conf_admin, alice, :create?
          refute_permit admin, alice, :create?
        end
      end
    end

    context 'user' do
      it 'cannot update admin information' do
        refute_permit bob, bob, :update?
      end

      it 'cannot update conf_admin information' do
        refute_permit bob, bob, :update?
      end

      it 'cannot update user information' do
        refute_permit bob, bob, :update?
      end
    end
  end

  context '#create' do
    it 'lets an admin create a new user' do
      assert_permit admin, User::Human, :create?
    end

    it 'lets a conf_admin create a new user' do
      assert_permit conf_admin, User::Human, :create?
    end

    it 'user cannot create a new user' do
      refute_permit bob, User::Human, :create?
    end

    context 'auth provider NOT db' do
      before do
        allow(AuthConfig).to receive(:db_enabled?).and_return(false)
      end
      it 'conf_admin cannot create new user' do
        refute_permit conf_admin, User::Human, :create?
      end
      it 'admin cannot create new user' do
        refute_permit admin, User::Human, :create?
      end

      it 'user cannot create new user' do
        refute_permit bob, User::Human, :create?
      end
    end
  end

  context '#unlock' do
    it 'lets an admin unlock an user' do
      assert_permit admin, bob, :unlock?
    end

    it 'lets a conf_admin unlock an user' do
      assert_permit conf_admin, bob, :unlock?
    end

    it 'lets a user not unlock an user' do
      refute_permit bob, bob, :unlock?
    end
  end

  context '#update_role' do
    context 'admin' do
      it 'cannot update a roots role' do
        refute_permit admin, root, :update_role?
      end

      it 'can update a users role' do
        assert_permit admin, bob, :update_role?
      end

      it 'can update a conf admins role' do
        assert_permit admin, conf_admin, :update_role?
      end

      it 'can update an admins role' do
        assert_permit admin, admin2, :update_role?
      end

      it 'cannot update himself' do
        refute_permit admin, admin, :update_role?
      end
    end

    context 'conf_admin' do
      it 'cannot update a roots role' do
        refute_permit conf_admin, root, :update_role?
      end

      it 'can update a users role' do
        assert_permit conf_admin, bob, :update_role?
      end

      it 'can update a conf admins role' do
        assert_permit conf_admin, conf_admin2, :update_role?
      end

      it 'cannot update an admins role' do
        refute_permit conf_admin, admin, :update_role?
      end

      it 'cannot update himself' do
        refute_permit conf_admin, conf_admin, :update_role?
      end
    end

    context 'user' do
      it 'cannot update a roots role' do
        refute_permit bob, root, :update_role?
      end

      it 'cannot update a users role' do
        refute_permit bob, alice, :update_role?
      end

      it 'cannot update a conf admins role' do
        refute_permit bob, conf_admin, :update_role?
      end

      it 'cannot update an admins role' do
        refute_permit bob, admin, :update_role?
      end

      it 'cannot update himself' do
        refute_permit bob, bob, :update_role?
      end
    end
  end

  context '#destroy' do
    context 'admin' do
      it 'cannot delete himself' do
        refute_permit admin, admin, :destroy?
      end

      it 'cannot destroy root' do
        refute_permit admin, root, :destroy?
      end

      it 'can destroy an admin' do
        assert_permit admin, admin2, :destroy?
      end

      it 'can destroy a conf_admin' do
        assert_permit admin, conf_admin, :destroy?
      end

      it 'can destroy a user' do
        assert_permit admin, bob, :destroy?
      end

      it 'can destroy a ldap user' do
        assert_permit admin, ldap_user, :destroy?
      end
    end

    context 'conf_admin' do
      it 'cannot destroy root' do
        refute_permit conf_admin, root, :destroy?
      end

      it 'cannot destroy an admin' do
        refute_permit conf_admin, admin, :destroy?
      end

      it 'cannot destroy a conf_admin' do
        refute_permit conf_admin, conf_admin, :destroy?
      end

      it 'can destroy a user' do
        assert_permit conf_admin, bob, :destroy?
      end

      it 'can destroy a ldap user' do
        assert_permit conf_admin, ldap_user, :destroy?
      end
    end

    context 'user' do
      it 'cannot destroy root' do
        refute_permit bob, root, :destroy?
      end

      it 'cannot destroy an admin' do
        refute_permit bob, admin, :destroy?
      end

      it 'cannot destroy a conf_admin' do
        refute_permit bob, conf_admin, :destroy?
      end

      it 'cannot destroy a user' do
        refute_permit bob, bob, :destroy?
      end

      it 'cannot destroy a ldap user' do
        refute_permit bob, ldap_user, :destroy?
      end
    end
  end

  context '#resetpassword' do
    context 'admin' do
      it 'can reset conf_admins password' do
        assert_permit admin, conf_admin, :resetpassword?
      end

      it 'can reset users password' do
        assert_permit admin, bob, :resetpassword?
      end

      it 'cannot reset his own password' do
        refute_permit admin, admin, :resetpassword?
      end
    end

    context 'conf_admin' do
      it 'cannot reset admins password' do
        refute_permit conf_admin, admin, :resetpassword?
      end

      it 'cannot reset conf_admins password' do
        refute_permit conf_admin, conf_admin, :resetpassword?
      end

      it 'can reset users password' do
        assert_permit conf_admin, bob, :resetpassword?
      end
    end

    context 'user' do
      it 'cannot reset a password' do
        refute_permit bob, bob, :resetpassword?
        refute_permit bob, alice, :resetpassword?
        refute_permit alice, bob, :resetpassword?
        refute_permit bob, admin, :resetpassword?
        refute_permit bob, conf_admin, :resetpassword?
      end
    end

    context 'auth provider NOT db' do
      before do
        allow(AuthConfig).to receive(:db_enabled?).and_return(false)
      end
      it 'is NOT possible to reset any passwords' do
        refute_permit root, bob, :resetpassword?
        refute_permit bob, bob, :resetpassword?
        refute_permit conf_admin, bob, :resetpassword?
        refute_permit conf_admin, alice, :resetpassword?
        refute_permit admin, alice, :resetpassword?
      end
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
