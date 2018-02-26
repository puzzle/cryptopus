require 'test_helper'

class SettingPolicyTest < PolicyTest 
  context '#index' do
    test 'admin can access admin/settings page' do
      assert_permit admin, Setting, :index?
    end

    test 'conf admin can access admin/settings page' do
      assert_permit conf_admin, Setting, :index?
    end
    
    test 'user cannot access admin/settings page' do
      refute_permit bob, Setting, :index?
    end
  end

  context '#update_all' do
    test 'admin can update settings' do
      assert_permit admin, Setting, :update_all?
    end
 
    test 'conf admin can update settings' do
      assert_permit conf_admin, Setting, :update_all?
    end   
    
    test 'user cannot update settings' do
      refute_permit bob, Setting, :update_all?
    end
  end
  
  context '#scope' do
    test 'admin receives settings' do
      assert_not_nil SettingPolicy::Scope.new(admin, Setting).resolve
    end
    
    test 'conf admin receives settings' do
      assert_not_nil SettingPolicy::Scope.new(conf_admin, Setting).resolve
    end

    test 'user does not receive settings' do
      assert_nil SettingPolicy::Scope.new(bob, Setting).resolve
    end
  end
end
