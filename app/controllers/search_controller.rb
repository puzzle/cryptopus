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

class SearchController < ApplicationController

  # GET /search
  def index

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /search
  def create
    user = User.find( :first, :conditions => ["uid = ?" , session[:uid]] )

    @accounts = Account.search params[:search_string]

    for account in @accounts do
      unless account.group.team.teammembers.find_by_user_id(user.id)
        @accounts.delete account
      end
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

end
