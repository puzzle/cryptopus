# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class StatusControllerTest < ActionController::TestCase
  def test_health
    endpoint_test :health
  end

  def test_readiness
    endpoint_test :readiness
  end

  private

  def endpoint_test(endpoint, status = :success, matcher = /ok/)
    get endpoint
    assert_response status
    assert_match matcher, response.body.to_s
  end
end
