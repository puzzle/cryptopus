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

require 'ldap_tools'

class AccountsController < ApplicationController
  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    unless params[:group_id].nil? 
      session[:active_group_id] = params[:group_id]
    end
    if session[:active_group_id].nil?
      redirect_to :controller => 'groups', :action => 'list'
      return
    end
    @accounts = Account.find(:all, :conditions => ["group_id = ?", session[:active_group_id]])
    @group_name = Group.find(:first , :conditions => ["id = ?", session[:active_group_id]]).name
    @team_name = Team.find(:first , :conditions => ["id = ?", session[:active_team_id]]).name
  end

  def show
    begin
      unless params[:id].nil?
        session[:active_account_id] = params[:id];
      end
      if session[:active_account_id].nil?
        redirect_to :action => 'list'
        return
      end
      
      @account = Account.find(:first, :conditions => ["id = ?", session[:active_account_id]] )
      decrypt_account
      @items = Item.find( :all, :conditions => ["account_id = ?", session[:active_account_id]] )

    rescue StandardError => message
      flash[:error] = message
      redirect_to :action => 'list'
 
    end
  end
  
  def move
    begin
      @account = Account.find(:first, :conditions => ["id = ?", session[:active_account_id] ] )
      @groups = Group.find(:all, :conditions => [ "team_id=?", session[:active_team_id] ] )
    
    rescue StandardError => message
      flash[:error] = message
      render :action => 'list'
    end
  end
  
  def change_group
    begin
      changed_account = Account.find(:first, :conditions => ["id = ?", session[:active_account_id] ] )
      changed_account.group_id = params[:new_group][:new_group_id]
      changed_account.save
      flash[:notice] = "Account was successfully moved"
      redirect_to :action => 'list'
      
    rescue StandardError => message
      flash[:error] = message
      redirect_to :action => 'list'
    end
  end

  def new
    if request.get?    
    else
      begin
        @account = Account.new( params[:account] )
	crypt_account
        @account.created_on = Time.now
        @account.group_id = session[:active_group_id]
        @account.save
      
      rescue StandardError => message
        flash[:error] = message
        render :action => 'new'
        return
      end
      flash[:notice] = 'Account was successfully created.'
      redirect_to :action => 'list'
    end
  end

  def edit
    if request.get?
      begin
        @account = Account.find(:first, :conditions => [ "id=?", params[:id] ] )
        decrypt_account
	@groups = Group.find( :all, :conditions => [ "team_id=?", session[:active_team_id] ] )
      
      rescue StandardError => message
        flash[:error] = message
        render :action => 'list'
      end
    else      
      begin
        @account = Account.find(:first, :conditions => [ "id=?", params[:id] ] )
        crypt_account
        @account.update_attributes( quote(params[:account]) )
  
      rescue StandardError => message
        flash[:error] = message
        render :action => 'edit'
        return
        
      end
      flash[:notice] = 'Account was successfully updated.'
      redirect_to :action => 'show', :id => @account
    end
  end
  
  def post_attachment
    begin
      @item = Item.new
      @item.account_id = session[:active_account_id]
      @item.description = params[:description]
      @item.filename = params[:file].original_filename
      @item.content_type = params[:file].content_type
      @item.file = CryptUtils.encrypt_blob( params[:file].read, get_team_password )
      @item.created_on = Time.now
      @item.updated_on = Time.now
      @item.save
      
    rescue StandardError => message
      flash[:error] = message      
    end
    redirect_to :action => 'show'
  end
  
  def send_attachment
    begin
      @item = Item.find(:first, :conditions => ["id = ?", params[:id] ] )
      file = CryptUtils.decrypt_blob( @item.file, get_team_password )
      send_data file, :filename => @item.filename , :type => @item.content_type, :disposition => params[:disposition]
    
    rescue StandardError => message
      flash[:notice] = message
      redirect_to :action => 'show'
      
    end
  end
  
  def destroy_attachment
    begin
      Item.find(:first, :conditions => ["id = ?", params[:id] ]).destroy
      
    rescue StandardError => message
      flash[:notice] = message
    
    end
    redirect_to :action => 'show'
  end

  def destroy
    Account.find( params[:id] ).destroy
    redirect_to :action => 'list'
  end

  def crypt_account
    @account.username = "none" if @account.username == "" or @account.username.nil?
    @account.password = "none" if @account.password == "" or @account.password.nil?
    @account.username = CryptUtils.encrypt_blob @account.username, get_team_password
    @account.password = CryptUtils.encrypt_blob @account.password, get_team_password
    @account.updated_on = Time.now
  end

  def decrypt_account
    @account.username = CryptUtils.decrypt_blob( @account.username, get_team_password )
    @account.password = CryptUtils.decrypt_blob( @account.password, get_team_password )
  end

end
