# frozen_string_literal: true

require 'spec_helper'
describe 'Create team' do
  include IntegrationHelpers::DefaultHelper
  include IntegrationHelpers::AccountTeamSetupHelper

  context 'as bob' do
    it 'creates new normal team' do
      # Setup for test
      credential = create_team_folder_encryptable('bob', 'password')

      # Create account link
      encryptable_path = api_encryptable_path(credential)

      # Bob can access team / accounts
      can_access_encryptable(encryptable_path, 'bob')

      # Root can access team / account
      can_access_encryptable(encryptable_path, 'root')

      # Admin can access team / account
      can_access_encryptable(encryptable_path, 'admin')
    end

    it 'creates private team' do
      # Setup for test
      credential = create_team_folder_encryptable_private('bob', 'password')

      # Create encryptable link
      encryptable_path = api_encryptable_path(credential)

      # Bob can not access team / encryptable
      can_access_encryptable(encryptable_path, 'bob')

      # Admin can not access team / encryptable
      cannot_access_encryptable(encryptable_path, 'admin')
    end
  end

end
