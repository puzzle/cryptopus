# frozen_string_literal: true

require 'rails_helper'

describe GroupPolicy do
  include PolicyHelper

  let(:group2) { groups(:group2) }
  let(:team2) { teams(:team2) }

  context 'as teammember' do
    it 'can show group' do
      assert_permit bob, group2, :show?
    end

    it 'can create a new group' do
      assert_permit bob, group2, :new?
    end

    it 'can create a new group with keypair' do
      assert_permit bob, group2, :create?
    end

    it 'can edit group' do
      assert_permit bob, group2, :edit?
    end

    it 'can update group' do
      assert_permit bob, group2, :update?
    end

    it 'can destroy group' do
      assert_permit bob, group2, :destroy?
    end
  end

  context 'as teammember' do
    it 'non teammember cannot show group' do
      refute_permit alice, group2, :show?
    end

    it 'non teammember cannot create a new group' do
      refute_permit alice, group2, :new?
    end

    it 'non teammember cannot create a new group with keypair' do
      refute_permit alice, group2, :create?
    end

    it 'non teammember cannot edit group' do
      refute_permit alice, group2, :edit?
    end

    it 'non teammember cannot update group' do
      refute_permit alice, group2, :update?
    end

    it 'non teammember cannot destroy group' do
      refute_permit alice, group2, :destroy?
    end
  end

  context 'as api user' do
    it 'is not allowed to show group' do
      expect do
        GroupPolicy.new(api_user, group2)
      end.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  private

  def api_user
    bobs_private_key = bob.decrypt_private_key('password')
    plaintext_team_password = team2.decrypt_team_password(bob, bobs_private_key)

    api_user = bob.api_users.create
    team2.add_user(api_user, plaintext_team_password)
    api_user
  end
end
