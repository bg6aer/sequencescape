#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012 Genome Research Ltd.
class DropUnnecessaryIndexesFromAssetLinks < ActiveRecord::Migration
  def self.up
    alter_table(:asset_links) do |t|
      t.remove_index(:name => 'index_asset_links_on_ancestor_id')
      t.remove_index(:name => 'index_asset_links_on_descendant_id')
    end
  end

  def self.down
    alter_table(:asset_links) do |t|
      t.index(:ancestor_id, :name => :index_asset_links_on_ancestor_id)
      t.index(:descendant_id, :name => :index_asset_links_on_descendant_id)
    end
  end
end
