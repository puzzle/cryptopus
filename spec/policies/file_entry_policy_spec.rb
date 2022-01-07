# frozen_string_literal: true

require 'spec_helper'

describe FileEntryPolicy do
  include PolicyHelper

  let(:account) { Account.find_by(name: 'account2') }
  let(:file_entry) { file_entries(:file_entry1) }

  context 'as teammember' do
    it 'can show file_entry' do
      assert_permit bob, file_entry, :show?
    end

    it 'can create a new file_entry' do
      assert_permit bob, file_entry, :create?
    end

    it 'can destroy file_entry' do
      assert_permit bob, file_entry, :destroy?
    end
  end

  context 'as non teammember' do
    before(:each) do
      remove_alice_from_team
    end

    it 'cannot show file_entry' do
      refute_permit alice, file_entry, :show?
    end

    it 'cannot create a new file_entry' do
      refute_permit alice, file_entry, :create?
    end

    it 'cannot destroy file_entry' do
      refute_permit alice, file_entry, :destroy?
    end
  end

  private

  def remove_alice_from_team
    teammembers(:team1_alice).destroy!
  end
end
