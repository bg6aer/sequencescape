#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2011,2012,2015 Genome Research Ltd.
Factory.define :empty_well, :class => Well do |well|
  well.value               ""
  well.qc_state            ""
  well.resource            nil
  well.barcode             nil
  well.well_attribute      {|wa| wa.association(:well_attribute)}
end

Factory.define :well, :parent => :empty_well do |a|
  # TODO: This should probably set an aliquot but test code (current) relies on it being empty
end

Factory.define :nameless_well, :class => Well do |well|
  well.value               ""
  well.qc_state            ""
  well.resource            nil
  well.barcode             nil
  well.well_attribute      {|wa| wa.association(:well_attribute)}
end

Factory.define :well_attribute do |w|
  w.concentration       23.2
  w.current_volume      15
end

Factory.define :well_with_sample_and_without_plate, :parent => :empty_well do |well|
  well.after_create do |well|
    well.aliquots.create!(:sample => Factory(:sample))
  end
end

Factory.define :tagged_well, :parent => :empty_well do |well|
  well.after_create do |well|
    well.aliquots.create!(:sample => Factory(:sample), :tag => Factory(:tag))
  end
end

Factory.define :well_with_sample_and_plate, :parent => :well_with_sample_and_without_plate do |well|
  well.map { |map| map.association(:map) }
  well.plate { |plate| plate.association(:plate) }
end
