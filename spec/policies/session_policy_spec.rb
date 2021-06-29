# frozen_string_literal: true

require 'spec_helper'

describe SessionPolicy do
  include PolicyHelper

  context 'not yet logged in user' do
    it 'may login' do
      assert_permit nil, :session, :new?
    end

    it 'may authenticate' do
      assert_permit nil, :session, :create?
    end

    it 'may not logout' do
      refute_permit nil, :session, :destroy?
    end
  end

  context 'already logged in user' do
    it 'may not login' do
      refute_permit bob, :session, :new?
    end

    it 'may not authenticate' do
      refute_permit bob, :session, :create?
    end

    it 'may logout' do
      assert_permit bob, :session, :destroy?
    end
  end
end
