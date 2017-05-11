# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'


describe LdapTools do

  describe "validation" do
    it "cannot login with invalid username" do
      assert_raises ActiveRecord::StatementInvalid do
        LdapTools.check_username("$invalid_username?")
      end
    end

    it "can login with valid username" do
      LdapTools.check_username("validUsername")
    end
  end

end
