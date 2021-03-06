#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013 Genome Research Ltd.
class AddNewIlluminaAPurposes < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do
      Pulldown::PlatePurposes.create_purposes(branch)

      tube_purpose = Tube::Purpose.find_by_name('Standard MX') or raise "Cannot find standard MX tube purpose"
      Purpose.find_by_name(branch.last).child_relationships.create!(:child => tube_purpose, :transfer_request_type => RequestType.transfer)
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      branch.shift
      branch.each {|name| Purpose.find_by_name(name).destroy }
    end
  end

  def self.branch
    [
      'Lib PCR-XP',
      'ISC-HTP lib pool',
      'ISC-HTP hyb',
      'ISC-HTP cap lib',
      'ISC-HTP cap lib PCR',
      'ISC-HTP cap lib PCR-XP',
      'ISC-HTP cap lib pool'
    ]
  end
end
