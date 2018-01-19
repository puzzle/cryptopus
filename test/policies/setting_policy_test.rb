require 'test_helper'

class SettingPolicyTest < PolicyTest 
  context '#index' do
    test 'admin can access admin/settings page' do
      assert_permit admin, Setting, :index?
    end
    
    test 'user cannot access admin/settings page' do
      refute_permit bob, Setting, :index?
    end
  end

  context '#update_all' do
    test 'admin can update settings' do
      assert_permit admin, Setting, :update_all?
    end
    
    test 'user cannot update settings' do
      refute_permit bob, Setting, :update_all?
    end
  end
end
