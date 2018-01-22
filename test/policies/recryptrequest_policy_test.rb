require 'test_helper'

class RecryptRequestPolicyTest < PolicyTest
  context '#index?' do
    test 'admin can see all recryptrequests' do
      assert admin.admin?
      recryptrequests = Pundit.policy_scope!(admin, Recryptrequest)
      Recryptrequest.all.each do |r|
        assert recryptrequests.include?(r)
      end
    end

    test 'normal user cant see pending recryptrequests' do
      assert_not bob.admin?
      recryptrequests = Pundit.policy_scope!(bob, Recryptrequest)
      assert_nil recryptrequests      
    end
  end

  context '#destroy?' do
    test 'admin can destroy a recryptrequest' do
      assert_permit admin, Recryptrequest, :destroy?
    end

    test 'non-admin cant destroy a recryptrequest' do
      assert_not bob.admin?
      refute_permit bob, Recryptrequest, :destroy?
    end
  end

  context '#new_ldap_password' do
    test 'non-ldap user cannot set a new ldap password' do
      assert_not bob.ldap?
      refute_permit bob, Recryptrequest, :new_ldap_password?
    end      

    test 'ldap user can set a new ldap password' do
      assert_permit ldap_user, Recryptrequest, :new_ldap_password? 
    end
  end

  context '#recrypt' do
    test 'everyone can trigger a recrypt request' do
      assert_permit admin, Recryptrequest, :recrypt? 
      assert_permit bob, Recryptrequest, :recrypt? 
      assert_permit alice, Recryptrequest, :recrypt? 
    end
  end
  
  private 

  def  ldap_user
    user = users(:bob)
    user.auth = 'ldap'
    user
  end
end
