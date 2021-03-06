#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2011 Genome Research Ltd.
class CreateAliquots < ActiveRecord::Migration
  def self.up
    create_table :aliquots do |t|
      t.references :receptacle, :null => false
      t.references :study
      t.references :project

      t.references :library
      t.references :sample,     :null => false
      t.references :tag

      t.string :library_type
      t.integer :insert_size_from
      t.integer :insert_size_to

      t.timestamps
    end

    add_index :aliquots, [ :receptacle_id, :tag_id ], :unique => true, :name => 'aliquot_tags_are_unique_within_receptacle'
  end

  def self.down
    drop_table :aliquots
  end
end
