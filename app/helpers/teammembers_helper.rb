module TeammembersHelper
  def teammember_list
    teammembers = @teammembers + @admins

    return teammembers if @team.noroot

    root = @teammembers.find_by(user_id: 1)
    teammembers.delete(root)
    teammembers.push(root)
  end

  def action_icon(teammember)
    if teammember.user.admin? || teammember.user.root?
      image_tag("penguin.png")
    else
      link_to_destroy [@team, teammember], teammember
    end
  end
end
