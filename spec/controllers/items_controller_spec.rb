# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  account_id   :integer          default(0), not null
#  description  :text
#  file         :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  filename     :text             not null
#  content_type :text             not null
#

require 'rails_helper'

describe ItemsController do
  include ControllerHelpers

  context 'POST create' do
    it 'does not upload file with empty file' do
      account1 = accounts(:account1)

      login_as(:bob)
      file = fixture_file_upload('files/empty.txt', 'text/plain')
      item_params = { filename: 'Testfile', content_typ: 'application/zip',
                      file: file, description: 'test' }

      expect do
        post :create, params: { team_id: teams(:team1), group_id: groups(:group1),
                                account_id: account1, item: item_params }
      end.to change { Item.count }.by(0)
    end

    it 'doesnt upload if no file and no item  params exist' do
      login_as(:bob)
      item_params = {}

      expect do
        expect do
          post :create, params: { team_id: teams(:team1), group_id: groups(:group1),
                                  account_id: accounts(:account1), item: item_params }
        end.to raise_error(ActionController::ParameterMissing)
      end.to change { Item.count }.by(0)
    end
  end
end
