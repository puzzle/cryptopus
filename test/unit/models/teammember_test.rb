require 'test_helper'
class TeammemberTest < ActiveSupport::TestCase
  test 'cannot remove last teammember' do
    team = teams(:team1)
    teammembers(:team1_root).delete
    teammembers(:team1_alice).delete
    teammembers(:team1_admin).delete

    # remove last teammember
    team1_bob = teammembers(:team1_bob)
    team1_bob.destroy
    assert team1_bob.persisted?
    assert_match /Cannot remove last teammember/, team1_bob.errors[:base].first
  end

  test 'remove teammember' do
    team = teams(:team1)
    team1_bob = teammembers(:team1_bob)
    team1_bob.destroy
    assert team1_bob.destroyed?
    assert team1_bob.errors.empty?
  end
end