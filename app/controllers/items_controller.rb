# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ItemsController < ApplicationController
  self.permitted_attrs = [:description, :file]

  helper_method :team

  # GET /accounts/1/items/new
  def new
    @item = account.items.new
    authorize @item

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /accounts/1/items
  def create
    authorize account

    respond_to do |format|
      create_item(format)
    end
  end

  # POST /accounts/1/items/1
  def show
    @item = account.items.find(params[:id])
    authorize @item

    file = @item.decrypt(plaintext_team_password(team))

    send_data file, filename: @item.filename, type: @item.content_type, disposition: 'attachment'
  end

  # DELETE /accounts/1/items/1
  def destroy
    @item = account.items.find(params[:id])
    authorize @item

    @item.destroy

    respond_to do |format|
      format.html { redirect_to account_url(@account) }
    end
  end

  private

  def account
    @account = Account.find(params[:account_id])
  end

  def group
    @group ||= account.group
  end

  def team
    @team ||= group.team
  end

  def create_item(format)
    item = Item.create(account, model_params, plaintext_team_password(team))
    if item.errors.empty?
      flash[:notice] = t('flashes.items.uploaded')
      format.html { redirect_to account_url(account) }
    else
      @item = item
      format.html { render action: 'new' }
    end
  end

end
