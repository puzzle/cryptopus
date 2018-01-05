# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class TeammemberSerializerTest < ActiveSupport::TestCase
  test 'teammember is not deletable if last teammember' do
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team2_bob)).to_json)

    assert_not as_json['deletable'], 'teammember should not be deletable'
  end

  test 'teammember is deletable if not last teammember and private team' do
    teams(:team1).update_attributes(private: true)
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_admin)).to_json)

    assert as_json['deletable'], 'teammember should be deletable'
  end

  test 'normal teammember is deletable if not last teammember in non_private team' do
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_bob)).to_json)

    assert as_json['deletable'], 'teammember should be deletable'
  end

  test 'admin teammember is not deletable in non_private team' do
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_admin)).to_json)

    assert_not as_json['deletable'], 'teammember should be deletable'
  end

  test 'admin is not a admin teammember if private team' do
    teams(:team1).update_attributes(private: true)
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_admin)).to_json)

    assert_not as_json['admin'], 'admin teammember should not be admin in private team'
  end

  test 'admin is admin teammember if non_private team' do
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_admin)).to_json)

    assert as_json['admin'], 'teammember should be admin'
  end

  test 'normal user is non admin teammember' do
    as_json = JSON.parse(TeammemberSerializer.new(teammembers(:team1_bob)).to_json)

    assert_not as_json['admin'], 'teammember should not be admin'
  end
end
