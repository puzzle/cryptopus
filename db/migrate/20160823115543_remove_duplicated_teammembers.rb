class RemoveDuplicatedTeammembers < ActiveRecord::Migration
  def up
    Teammember.all.each do |tm| 
      if Teammember.where(user_id: tm.user_id, team_id: tm.team_id).count > 1
        tm.destroy
      end
    end
  end

  def down; end
end
