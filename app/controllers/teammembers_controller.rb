# $Id$
#
# Copyright (c) 2007 Puzzle ITC GmbH. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class TeammembersController < ApplicationController
  before_filter :load_team
  helper_method :teammember_canditates

  # GET /teams/1/teammembers/new
  def new

  end

  # POST /teams/1/teammembers
  def create
    begin
      user = User.find_by_username params[:username]
      raise "User is not in the database" if user.nil?
      raise "User is already in that Team" \
        if @team.teammembers.where("user_id = ?", user.id).first
      @teammember = Teammember.new
      @teammember.team_id = @team.id
      @teammember.user_id = user.id
      @teammember.password = CryptUtils.encrypt_team_password( get_team_password(@team), user.public_key)
      @teammember.save

    rescue StandardError => e
      flash[:error] = e.message
    end

    respond_to do |format|
      format.html { redirect_to team_groups_url(@team) }
    end
  end

  # DELETE /teams/1/teammembers/1
  def destroy
    if @team.teammembers.count == 1
      flash[:error] = t('flashes.teammembers.could_not_remove_last_teammember')
    else
      @teammember = @team.teammembers.find( params[:id] )
      @teammember.destroy
    end
    respond_to do |format|
      format.html { redirect_to team_groups_url(@team) }
    end
  end

  private

    def load_team
      @team = Team.find( params[:team_id] )
    end

    def teammember_canditates
      users = @team.teammember_candidates
      user_list = users.collect {|user| [ user.full_name, user.username ]}
      user_list.sort!
    end
end
