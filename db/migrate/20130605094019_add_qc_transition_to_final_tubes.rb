#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013 Genome Research Ltd.
class AddQcTransitionToFinalTubes < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      branches.each do |branch|
        Purpose.find_by_name!(branch.first).child_relationships.clear
        IlluminaHtp::PlatePurposes.create_branch(branch)
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      branches.each do |branch|
        Purpose.find_by_name!(branch.first).child_relationships.clear
        Purpose.find_by_name!(branch.first).child_relationships.create!(:child => Purpose.find_by_name(branch.last), :transfer_request_type => RequestType.transfer)
      end
    end
  end

  def self.branches
    [['Lib Pool','Lib Pool Norm'],['Lib Pool SS-XP', 'Lib Pool SS-XP-Norm' ]]
  end
end
