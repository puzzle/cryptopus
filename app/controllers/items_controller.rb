#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ItemsController < ApplicationController
  before_action :load_parents
  helper_method :team

  # GET /teams/1/groups/1/accounts/new
  def new
    @item = @account.items.new
    authorize @item

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams/1/groups/1/accounts/1/items
  def create
    respond_to do |format|
      item = Item.create(@account, item_params, plaintext_team_password(team))
      authorize item
      if item.errors.empty?
        flash[:notice] = t('flashes.items.uploaded')
        format.html { redirect_to team_group_account_url(team, @group, @account) }
      else
        @item = item
        format.html { render action: 'new' }
      end
      #display_item(item)
    end
  end

  # POST /teams/1/groups/1/accounts/1/items/1
  def show
    @item = @account.items.find(params[:id])
    authorize @item
    file = @item.decrypt(plaintext_team_password(team))

    send_data file, filename: @item.filename, type: @item.content_type, disposition: 'attachment'
  end

  # DELETE /teams/1/groups/1/accounts/1/items/1
  def destroy
    @item = @account.items.find(params[:id])
    authorize @item
    @item.destroy

    respond_to do |format|
      format.html { redirect_to team_group_account_url(team, @group, @account) }
    end
  end

  private

  def item_params
    params.require(:item).permit(:description, :file)
  end

  def load_parents
    @group = team.groups.find(params[:group_id])
    @account = @group.accounts.find(params[:account_id])
  end

  def display_item(item)
    if item.errors.empty?
      flash[:notice] = t('flashes.items.uploaded')
      format.html { redirect_to team_group_account_url(team, @group, @account) }
    else
      @item = item
      format.html { render action: 'new' }
    end
  end

end
