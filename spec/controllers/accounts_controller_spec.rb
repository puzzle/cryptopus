# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  accountname :string(70)       default(""), not null
#  group_id    :integer          default(0), not null
#  description :text
#  username    :binary
#  password    :binary
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tag         :string
#

require 'rails_helper'

describe AccountsController do
  include ControllerHelpers

  context 'GET show' do
    it 'shows an error message if you attempt to look into a team youre not member of' do
      login_as(:alice)

      account2 = accounts(:account2)

      get :show, params: { id: account2 }

      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
    end

    context 'breadcrumbs' do
      render_views
      it 'shows breadcrumb path 1 if the user is on index of accounts' do
        login_as(:bob)

        account1 = accounts(:account1)

        get :show, params: { id: account1 }

        expect(response.body).to match(/Teams/)
        expect(response.body).to match(/team1/)
        expect(response.body).to match(/group1/)
        expect(response.body).to match(/account1/)
      end
    end
  end

  context 'DELETE destroy' do
    it 'cant destroy an account if not in team' do
      login_as(:alice)

      alice = users(:alice)
      team2 = teams(:team2)
      account = team2.groups.first.accounts.first

      expect(team2.teammember?(alice)).to eq false

      expect do
        delete :destroy, params: { id: account.id, group_id: account.group.id,
                                   team_id: account.group.team.id }
      end.to change { Account.count }.by(0)
    end

    it 'can destroy an account if human user is in his team' do
      account = accounts(:account1)

      login_as(:bob)

      expect do
        delete :destroy, params: { id: account.id, group_id: account.group.id,
                                   team_id: account.group.team.id }
      end.to change { Account.count }.by(-1)
    end
  end
end
