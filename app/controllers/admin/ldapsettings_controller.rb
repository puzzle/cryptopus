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

class Admin::LdapsettingsController < Admin::AdminController

  # GET /ldapsettings
  def index
    @ldapsetting = Ldapsetting.first
    if @ldapsetting.nil?
      flash[:notice] = t('flashes.admin.ldapsettings.example')
      @ldapsetting = Ldapsetting.new
      @ldapsetting.save
    end
  end

  # PUT /ldapsettings/1
  def update
    @ldapsetting = Ldapsetting.first

    respond_to do |format|
      if @ldapsetting.update_attributes( params[:ldapsetting] )
        flash[:notice] = t('flashes.admin.ldapsettings.ldap')
        format.html { redirect_to teams_path }
      else
        format.html { redirect_to admin_ldapsettings_path }
      end
    end
  end

end
