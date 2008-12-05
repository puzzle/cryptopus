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

class LdapsettingsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :update ],
         :redirect_to => { :action => :edit }


  def edit
    if request.get?
      begin
        @ldapsetting = Ldapsetting.find(:first)
        if @ldapsetting.nil?
          flash[:notice] = "This are example settings. Please overwrite them with your settings."
          @ldapsetting = Ldapsetting.new
          @ldapsetting.save
        end
        
      rescue StandardError => message
        flash[:error] = message
        redirect_to :controller => 'teams', :action => 'list'
        return
      end
    else
      begin
        @ldapsetting = Ldapsetting.find(:first)
        @ldapsetting.update_attributes(params[:ldapsetting])
        
      rescue StandardError => message
        flash[:error] = message
        return
      end
      flash[:notice] = 'Your LDAD settings were successfully updated.'
      redirect_to :controller => 'teams', :action => 'list'
    end
  end
  
end
