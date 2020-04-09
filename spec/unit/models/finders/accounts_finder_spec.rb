# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Finders::AccountsFinder do

  context 'as teammember' do
    it 'finds his accounts' do
      accounts = find(Account.all, 'account1')
      expect(accounts.count).to eq(1)
      expect(accounts.first.accountname).to eq('account1')
    end

    it 'does not find an account with invalid query' do
      accounts = find(Account.all, '42account42')
      expect(accounts.count).to eq(0)
    end
  end

  private

  def find(accounts, query)
    Finders::AccountsFinder.new(accounts, query).apply
  end
end
