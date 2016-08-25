class RemoveDuplicatedTeammembers < ActiveRecord::Migration
  def up
    seen = Set.new
    Teammember.all.each do |tm| 
      key = [tm.user_id, tm.team_id]
      if seen.include?(key)
        tm.destroy
      else 
        seen.add(key)
      end      
    end
  end

  def down; end
end
