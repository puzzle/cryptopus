# encoding: utf-8
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

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  setup do
    GeoIp.stubs(:activated?)
  end

  context 'move' do
    test 'move account from one group to another' do
      login_as (:bob)

      account1 = accounts(:account1)
      group1 = groups(:group1)
      team1 = teams(:team1)
      group2 = team1.groups.new(id: 12, name: 'Test', description: 'group_description')
      group2.save

      patch :update, params: {id: account1, group_id: group1, team_id: team1, account: {group_id: group2} }
      account1.reload

      assert_equal account1.group_id, group2.id
    end
  end

  context 'breadcrumbs' do
    test 'show breadcrumb path 1 if user is on index of accounts' do
      login_as (:bob)

      group1 = groups(:group1)
      team1 = teams(:team1)

      get :index, params: { group_id: group1, team_id: team1 }
      assert_select '.breadcrumb', text: 'Teamsteam1group1'
      assert_select '.breadcrumb a', count: 2
      assert_select '.breadcrumb a', text: 'Teams'
      assert_select '.breadcrumb a', text: 'team1'
      assert_select '.breadcrumb a', text: 'group1', count: 0
    end

    test 'show breadcrump path 2 if user is on edit of accounts' do
      login_as (:bob)

      group1 = groups(:group1)
      team1 = teams(:team1)
      account1 = accounts(:account1)

      get :edit, params: { id: account1, group_id: group1, team_id: team1 }
      assert_select '.breadcrumb', text: 'Teamsteam1group1account1'
      assert_select '.breadcrumb a', count: 3
      assert_select '.breadcrumb a', text: 'Teams'
      assert_select '.breadcrumb a', text: 'team1'
      assert_select '.breadcrumb a', text: 'group1'
      assert_select '.breadcrumb a', text: 'account1', count: 0
    end
  end

  context 'move' do
    test 'cant move account if not part of team' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = {group_id: groups(:group1)}

      login_as(:alice)

      put :move, params: { account_id: account.id, group_id: group.id, team_id: team.id, account: account_params}

      account.reload

      assert_not_equal accounts(:account2).group.id, groups(:group1).id
    end

    test 'teammember can move account' do
      account = accounts(:account2)
      group = groups(:group2)
      team = teams(:team2)

      account_params = {group_id: groups(:group1)}

      login_as(:bob)

      put :move, params: { account_id: account.id, group_id: group.id, team_id: team.id, account: account_params}

      account.reload

      assert_equal account.group.id, groups(:group1).id
    end
  end

  context 'destroy' do
    test 'cant destroy an account if not in team' do
      alice = users(:alice)
      team2 = teams(:team2)
      account = team2.groups.first.accounts.first

      assert_equal false, team2.teammember?(alice)

      login_as(:alice)

      assert_difference('Account.count', 0) do
        delete :destroy, params: { id: account.id, group_id: account.group.id, team_id: account.group.team.id }
      end
    end

    test 'human user can destroy an account in his team' do
      account = accounts(:account1)

      login_as(:bob)

      assert_difference('Account.count', -1) do
        delete :destroy, params: { id: account.id, group_id: account.group.id, team_id: account.group.team.id}
      end
    end
  end

  context 'index' do
    test 'Error message if you attempt to look into a team youre not member of' do
      team2 = teams(:team2)
      group2 = groups(:group2)

      login_as(:alice)

      get :index, params: { team_id: team2, group_id: group2 }

      assert_match(/Access denied/, flash[:error])
      assert_redirected_to teams_path
    end
  end

  context 'create' do
    test 'can create account without username and password' do
      login_as(:bob)

      params = { 'accountname'=>'test',
                 'cleartext_username'=>'',
                 'cleartext_password'=>'test',
                 'description'=>'test' }

      post :create, params: { team_id: teams(:team1), group_id: groups(:group1), account: params }

      assert_equal '', Account.find_by(accountname: 'test').username
    end
  end
end
