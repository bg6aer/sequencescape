#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2012 Genome Research Ltd.
class SetTransferRequestTypeOnPlatePurposeRelationships < ActiveRecord::Migration
  class PlatePurposeRelationship < ActiveRecord::Base
    set_table_name('plate_purpose_relationships')
    belongs_to :transfer_request_type, :class_name => 'SetTransferRequestTypeOnPlatePurposeRelationships::RequestType'
  end

  class RequestType < ActiveRecord::Base
    set_table_name('request_types')

    def self.transfer
      @transfer ||= self.find_by_key('transfer') or raise "Cannot find transfer request type"
    end
  end

  def self.up
    ActiveRecord::Base.transaction do
      PlatePurposeRelationship.find_each do |relation|
        relation.update_attributes!(:transfer_request_type => RequestType.transfer)
      end
    end
  end

  def self.down
    # Nothing to do here
  end
end
