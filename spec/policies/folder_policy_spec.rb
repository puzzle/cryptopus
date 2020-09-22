# frozen_string_literal: true

require 'rails_helper'

describe FolderPolicy do
  include PolicyHelper

  let(:folder2) { folders(:folder2) }
  let(:team2) { teams(:team2) }

  context 'as teammember' do
    it 'can show folder' do
      assert_permit bob, folder2, :show?
    end

    it 'can create a new folder' do
      assert_permit bob, folder2, :new?
    end

    it 'can create a new folder with keypair' do
      assert_permit bob, folder2, :create?
    end

    it 'can edit folder' do
      assert_permit bob, folder2, :edit?
    end

    it 'can update folder' do
      assert_permit bob, folder2, :update?
    end

    it 'can destroy folder' do
      assert_permit bob, folder2, :destroy?
    end
  end

  context 'as teammember' do
    it 'non teammember cannot show folder' do
      refute_permit alice, folder2, :show?
    end

    it 'non teammember cannot create a new folder' do
      refute_permit alice, folder2, :new?
    end

    it 'non teammember cannot create a new folder with keypair' do
      refute_permit alice, folder2, :create?
    end

    it 'non teammember cannot edit folder' do
      refute_permit alice, folder2, :edit?
    end

    it 'non teammember cannot update folder' do
      refute_permit alice, folder2, :update?
    end

    it 'non teammember cannot destroy folder' do
      refute_permit alice, folder2, :destroy?
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
