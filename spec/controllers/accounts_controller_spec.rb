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

    it 'shows an error if you look into a team if youre admin and not member of' do
      login_as(:admin)

      account2 = accounts(:account2)

      get :show, params: { id: account2 }

      expect(flash[:error]).to match(/Access denied/)
      expect(response).to redirect_to teams_path
    end

    it 'shows an error if you look into a team if youre conf_admin and not member of' do
      login_as(:tux)

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

      it 'shows breadcrumb path 1 if the admin is on index of accounts' do
        login_as(:admin)

        account1 = accounts(:account1)

        get :show, params: { id: account1 }

        expect(response.body).to match(/Teams/)
        expect(response.body).to match(/team1/)
        expect(response.body).to match(/group1/)
        expect(response.body).to match(/account1/)
      end

      it 'redirects if the conf_admin is on index of accounts' do
        login_as(:tux)

        account1 = accounts(:account1)

        get :show, params: { id: account1 }

        assert_redirected_to teams_path
      end
    end
  end

  context 'POST create' do
    it 'can create an account without username and password' do
      login_as(:bob)
      group_id = groups(:group1).id

      params = { 'accountname' => 'test',
                 'cleartext_username' => '',
                 'cleartext_password' => 'test',
                 'description' => 'test',
                 'group_id' => group_id }

      expect do
        post :create, params: { account: params }
      end.to change { Account.count }.by(1)

      created_account = Account.find_by(accountname: 'test')
      expect(created_account.username).to eq ''
      expect(created_account.description).to eq 'test'
      expect(created_account.group).to eq groups(:group1)
    end

    it 'can create an account without username and password if admin' do
      login_as(:admin)
      group_id = groups(:group1).id

      params = { 'accountname' => 'test',
                 'cleartext_username' => '',
                 'cleartext_password' => 'test',
                 'description' => 'test',
                 'group_id' => group_id }

      expect do
        post :create, params: { account: params }
      end.to change { Account.count }.by(1)

      created_account = Account.find_by(accountname: 'test')
      expect(created_account.username).to eq ''
      expect(created_account.description).to eq 'test'
      expect(created_account.group).to eq groups(:group1)
    end

    it 'cannot create an account without username and password if conf_admin' do
      login_as(:tux)
      group_id = groups(:group1).id

      params = { 'accountname' => 'test',
                 'cleartext_username' => '',
                 'cleartext_password' => 'test',
                 'description' => 'test',
                 'group_id' => group_id }

      expect do
        post :create, params: { account: params }
      end.to change { Account.count }.by(0)

      expect(groups(:group1)).to eq Group.find_by(id: group_id)
    end
  end

  context 'PATCH update' do
    context 'move' do
      it 'moves an account from one group to another' do
        login_as(:bob)

        account1 = accounts(:account1)
        team1 = teams(:team1)
        group2 = team1.groups.create(name: 'Test', description: 'group_description')

        patch :update, params: { id: account1, account: { group_id: group2 } }
        account1.reload

        expect(group2.id).to eq account1.group_id
      end

      it 'moves an account from one group to another if admin' do
        login_as(:admin)

        account1 = accounts(:account1)
        team1 = teams(:team1)
        group2 = team1.groups.create(name: 'Test', description: 'group_description')

        patch :update, params: { id: account1, account: { group_id: group2 } }
        account1.reload

        expect(group2.id).to eq account1.group_id
      end

      it 'cannot move an account from one group to another if conf_admin' do
        login_as(:tux)

        account1 = accounts(:account1)
        team1 = teams(:team1)
        group2 = team1.groups.create(name: 'Test', description: 'group_description')

        patch :update, params: { id: account1, account: { group_id: group2 } }
        account1.reload

        expect(group2.id).not_to eq account1.group_id
      end
    end
  end

  context 'GET edit' do
    context 'breadcrumbs' do
      render_views

      it 'shows breadcrumb path 2 if the user is on edit of accounts' do
        login_as(:bob)

        group1 = groups(:group1)
        team1 = teams(:team1)
        account1 = accounts(:account1)

        get :edit, params: { id: account1, group_id: group1, team_id: team1 }

        expect(response.body).to match(/Teams/)
        expect(response.body).to match(/team1/)
        expect(response.body).to match(/group1/)
        expect(response.body).to match(/account1/)
      end

      it 'shows breadcrumb path 2 if the admin is on edit of accounts' do
        login_as(:bob)

        group1 = groups(:group1)
        team1 = teams(:team1)
        account1 = accounts(:account1)

        get :edit, params: { id: account1, group_id: group1, team_id: team1 }

        expect(response.body).to match(/Teams/)
        expect(response.body).to match(/team1/)
        expect(response.body).to match(/group1/)
        expect(response.body).to match(/account1/)
      end

      it 'redirects if conf_admin is on edit account from which he doesnt have rights' do
        login_as(:tux)

        group1 = groups(:group1)
        team1 = teams(:team1)
        account1 = accounts(:account1)

        get :edit, params: { id: account1, group_id: group1, team_id: team1 }

        assert_redirected_to teams_path
      end
    end
  end

  context 'PUT move' do
    it 'cant move account if not part of team' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = { group_id: groups(:group1) }

      login_as(:alice)

      put :move, params: { id: account.id, group_id: group.id, team_id: team.id,
                           account: account_params }

      account.reload

      expect(response).to have_http_status(302)
      expect(accounts(:account2).group.id).not_to equal groups(:group1).id
    end

    it 'cant move account if not part of team as admin' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = { group_id: groups(:group1) }

      login_as(:admin)

      put :move, params: { id: account.id, group_id: group.id, team_id: team.id,
                           account: account_params }

      account.reload

      expect(response).to have_http_status(302)
      expect(accounts(:account2).group.id).not_to equal groups(:group1).id
    end

    it 'cant move account if not part of team as conf_admin' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = { group_id: groups(:group1) }

      login_as(:alice)

      put :move, params: { id: account.id, group_id: group.id, team_id: team.id,
                           account: account_params }

      account.reload

      expect(response).to have_http_status(302)
      expect(accounts(:account2).group.id).not_to equal groups(:group1).id
    end

    it 'can move account if part of team' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = { group_id: groups(:group1) }

      login_as(:bob)

      put :move, params: { id: account.id, group_id: group.id, team_id: team.id,
                           account: account_params }

      account.reload

      expect(groups(:group1).id).to eq account.group.id
    end

    it 'cannot move account if user part of team as admin' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = { group_id: groups(:group1) }

      login_as(:admin)

      put :move, params: { id: account.id, group_id: group.id, team_id: team.id,
                           account: account_params }

      account.reload

      expect(groups(:group1).id).not_to eq account.group.id
    end

    it 'can move account if user part of team as conf_admin' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = { group_id: groups(:group1) }

      login_as(:bob)

      put :move, params: { id: account.id, group_id: group.id, team_id: team.id,
                           account: account_params }

      account.reload

      expect(groups(:group1).id).to eq account.group.id
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

    it 'cannot destroy an account if not in team as admin' do
      login_as(:admin)

      alice = users(:alice)
      team2 = teams(:team2)
      account = team2.groups.first.accounts.first

      expect(team2.teammember?(alice)).to eq false

      expect do
        delete :destroy, params: { id: account.id, group_id: account.group.id,
                                   team_id: account.group.team.id }
      end.to change { Account.count }.by(0)
    end

    it 'cant destroy an account if not in team as conf_admin' do
      login_as(:tux)

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

    it 'can destroy an account if human admin is in his team' do
      account = accounts(:account1)

      login_as(:admin)

      expect do
        delete :destroy, params: { id: account.id, group_id: account.group.id,
                                   team_id: account.group.team.id }
      end.to change { Account.count }.by(-1)
    end

    it 'cannot destroy an account if human conf_admin is in his team' do
      account = accounts(:account1)

      login_as(:tux)

      expect do
        delete :destroy, params: { id: account.id, group_id: account.group.id,
                                   team_id: account.group.team.id }
      end.to change { Account.count }.by(0)
    end
  end
end
