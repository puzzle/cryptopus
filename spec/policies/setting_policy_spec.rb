# frozen_string_literal: true

require 'spec_helper'

describe SettingPolicy do
  include PolicyHelper

  context 'as admin' do
    it 'can access admin/settings page' do
      assert_permit admin, Setting, :index?
    end

    it 'can update settings' do
      assert_permit admin, Setting, :update?
    end
  end
  context 'as conf_admin' do
    it 'can access admin/settings page' do
      assert_permit conf_admin, Setting, :index?
    end

    it 'can update settings' do
      assert_permit conf_admin, Setting, :update?
    end
  end
  context 'as non-admin' do
    it 'cannot access admin/settings page' do
      refute_permit bob, Setting, :index?
    end

    it 'cannot update settings' do
      refute_permit bob, Setting, :update?
    end
  end
end
