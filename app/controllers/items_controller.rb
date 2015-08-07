# $Id$

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

class ItemsController < ApplicationController
  before_filter :load_parents

private

  def load_parents
    @team = Team.find( params[:team_id] )
    @group = @team.groups.find( params[:group_id] )
    @account = @group.accounts.find( params[:account_id] )
  end

public

  # GET /teams/1/groups/1/accounts/new
  def new
    @item = @account.items.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /teams/1/groups/1/accounts/1/items
  def create
    datafile = params[:item][:file]
    @item = @account.items.new
    @item.description = params[:item][:description]
    @item.filename = datafile.original_filename
    @item.content_type = datafile.content_type
    @item.file = CryptUtils.encrypt_blob( datafile.read, get_team_password(@team) )
    @item.created_on = Time.now
    @item.updated_on = Time.now

    respond_to do |format|
      if @item.save
        flash[:notice] = t('flashes.items.uploaded')
      end
      format.html { redirect_to team_group_account_url(@team, @group, @account) }
    end
    session[:jumpto][:item].delete(:file)
  end

  # POST /teams/1/groups/1/accounts/1/items/1
  def show
    @item = @account.items.find( params[:id] )
    file = CryptUtils.decrypt_blob( @item.file, get_team_password(@team) )

    send_data file, :filename => @item.filename , :type => @item.content_type, :disposition => 'attachment'
  end

  # DELETE /teams/1/groups/1/accounts/1/items/1
  def destroy
    @item = @account.items.find( params[:id] )
    @item.destroy

    respond_to do |format|
      format.html { redirect_to team_group_account_url(@team, @group, @account) }
    end
  end

end
