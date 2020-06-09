# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe Finders::FoldersFinder do

  context 'as teammember' do
    it 'finds his folders' do
      folders = find(Folder.all, 'folder1')
      expect(folders.count).to eq(1)
      expect(folders.first.name).to eq('folder1')
    end

    it 'does not find a folder with invalid query' do
      folders = find(Folder.all, '42folder42')
      expect(folders.count).to eq(0)
    end
  end

  private

  def find(folders, query)
    Finders::FoldersFinder.new(folders, query).apply
  end
end
