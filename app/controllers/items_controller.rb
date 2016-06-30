# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ItemsController < ApplicationController
  before_filter :load_parents
  helper_method :team

  # GET /teams/1/groups/1/accounts/new
  def new
    @item = @account.items.new

    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # POST /teams/1/groups/1/accounts/1/items
  def create
    datafile = params[:item][:file]
    datafile.nil? ? flash[:error] = t('flashes.items.uploaded_file_inexistent') : create_item(datafile)

    respond_to do |format|
      format.html { redirect_to team_group_account_url(team, @group, @account) }
    end
  end

  # POST /teams/1/groups/1/accounts/1/items/1
  def show
    @item = @account.items.find(params[:id])
    file = CryptUtils.decrypt_blob(@item.file, plaintext_team_password(team))

    send_data file, filename: @item.filename, type: @item.content_type, disposition: 'attachment'
  end

  # DELETE /teams/1/groups/1/accounts/1/items/1
  def destroy
    @item = @account.items.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to team_group_account_url(team, @group, @account) }
    end
  end

  private

  def load_parents

    @group = team.groups.find(params[:group_id])
    @account = @group.accounts.find(params[:account_id])
  end

  def create_item(datafile)
    @item = @account.items.new
    @item.description = params[:item][:description]
    @item.filename = datafile.original_filename
    @item.content_type = datafile.content_type

    if valid_item?(@item, datafile)
      @item.file = CryptUtils.encrypt_blob(datafile.read, plaintext_team_password(team))
      flash[:notice] = t('flashes.items.uploaded') if @item.save
    end
  end


  def valid_item?(item, datafile)
    flash[:error] = t('flashes.items.uploaded_filename_is_empty') if item.filename.blank?
    flash[:notice] = t('activerecord.errors.models.item.attributes.filename.taken') unless item.valid?
    flash[:error] = t('flashes.items.uploaded_size_to_high') if datafile.size > 10_000_000 # 10MB

    flash[:error].blank? && flash[:notice].blank?
  end
end
