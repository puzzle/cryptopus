require 'test_helper'

class TeamPolicyTest < PolicyTest
  context '#index' do
    test 'admin sees all non-private teams' do

    end

    test 'user can see all teams he is a part of' do

    end

    test 'user cannot see teams he isnt a part of' do

    end
  end

  context '#update' do
    test 'teammember can edit a team' do
      
    end

    test 'non-teammember cannot edit a team' do

    end

    test 'admin can edit a public team' do

    end

    test 'admin cannot edit a non-public team' do

    end
  end

  context '#destroy' do
    test 'non-teammember cannot delete a team'do

    end

    test 'teammember can delete a team' do

    end

    test 'admin can delete any team' do

    end
  end
end
