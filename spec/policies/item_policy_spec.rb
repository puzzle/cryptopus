# frozen_string_literal: true

require 'rails_helper'

describe ItemPolicy do
  include PolicyHelper

  let(:account) { Account.find_by(accountname: 'account2') }
  let(:item) { items(:item1) }

  before(:each) do
    remove_alice_from_team
  end

  context 'as teammember' do
    it 'can show item' do
      assert_permit bob, item, :show?
    end

    it 'can create a new item' do
      assert_permit bob, item, :new?
    end

    it 'can create a new item with keypair' do
      assert_permit bob, account, :create_item?
    end

    it 'can destroy item' do
      assert_permit bob, item, :destroy?
    end
  end

  context 'as non teammember' do
    it 'cannot show item' do
      refute_permit alice, item, :show?
    end

    it 'cannot create a new item' do
      refute_permit alice, item, :new?
    end

    it 'cannot create a new item with keypair' do
      refute_permit alice, account, :create_item?
    end

    it 'cannot destroy item' do
      refute_permit alice, item, :destroy?
    end
  end

  private

  def remove_alice_from_team
    team1 = Team.find_by(name: 'team1')
    teammember = team1.teammembers.find_by(id: 2367674)
    teammember.destroy!
  end
end
