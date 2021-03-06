#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012 Genome Research Ltd.
class ProductLine < ActiveRecord::Base; end
 
class AddProductLines < ActiveRecord::Migration
  def self.up
    create_table :product_lines do |t|
      t.string :name, :null => false
    end


    ActiveRecord::Base.transaction do
      %w{Illumina-A Illumina-B Illumina-C}.each do |product_line_name|
        say "Adding default Product Lines for #{product_line_name}."
        ProductLine.create!(:name => product_line_name)
      end
    end

    say 'Adding ProductLine assocication column to SubmissionTemplate'
    add_column :submission_templates, :product_line_id, :integer
  end

  def self.down
    remove_column :submission_templates, :product_line_id
    drop_table :product_lines
  end
end
