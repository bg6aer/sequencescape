#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2007-2011,2011,2012,2013,2014 Genome Research Ltd.
def set_uuid_for(object, uuid_value)
  uuid   = object.uuid_object
  uuid ||= object.build_uuid_object
  uuid.external_id = uuid_value
  uuid.save(false)
end

ALL_MODELS_THAT_CAN_HAVE_UUIDS_BASED_ON_NAME = [
  'sample',
  'study',
  'project',
  'sample tube',
  'library tube',
  'pulldown multiplexed library tube',
  'multiplexed library tube',
  'stock multiplexed library tube',
  'PacBio library tube',
  'well',
  'asset rack',
  'plate',
  'project',
  'submission template',
  'asset group',
  'request type',
  'search',
  'control plate',
  'dilution plate',
  'gel dilution plate',
  'pico assay a plate',
  'pico assay b plate',
  'pico assay plate',
  'pico dilution plate',
  'plate purpose',
  'purpose',
  'plate',
  'sequenom qc plate',
  'working dilution plate',
  'pipeline',
  'supplier',
  'transfer template',
  'tag layout template',
  'barcode printer',
  'tube',
  'tag group',
  'robot',
  'reference genome'
]

SINGULAR_MODELS_BASED_ON_NAME_REGEXP = ALL_MODELS_THAT_CAN_HAVE_UUIDS_BASED_ON_NAME.join('|')
PLURAL_MODELS_BASED_ON_NAME_REGEXP   = ALL_MODELS_THAT_CAN_HAVE_UUIDS_BASED_ON_NAME.map(&:pluralize).join('|')

# This may create invalid UUID external_id values but it means that we don't have to conform to the
# standard in our features.
Given /^the UUID for the (#{SINGULAR_MODELS_BASED_ON_NAME_REGEXP}) "([^\"]+)" is "([^\"]+)"$/ do |model,name,uuid_value|
  object = model.gsub(/\s+/, '_').classify.constantize.find_by_name(name) or raise "Cannot find #{ model } #{ name.inspect }"
  set_uuid_for(object, uuid_value)
end

Given /^the UUID for the last asset rack purpose is "(.*?)"$/ do |uuid_value|
  object = AssetRack::Purpose.last or raise "Cannot find asset rack purpose"
  set_uuid_for(object, uuid_value)
end

Given /^an? (#{SINGULAR_MODELS_BASED_ON_NAME_REGEXP}) called "([^\"]+)" with UUID "([^\"]+)"$/ do |model,name,uuid_value|
  set_uuid_for(Factory(model.gsub(/\s+/, '_').to_sym, :name => name), uuid_value)
end

Given /^a tube purpose called "([^\"]+)" with UUID "([^\"]+)"$/ do |name,uuid_value|
  set_uuid_for(Factory(:tube_purpose, :name => name), uuid_value)
end

Given /^an asset rack purpose called "(.*?)" with UUID "(.*?)"$/ do |name,uuid_value|
set_uuid_for( Factory(:asset_rack_purpose, :name => name), uuid_value )
end

Given /^an? (#{SINGULAR_MODELS_BASED_ON_NAME_REGEXP}) called "([^\"]+)" with ID (\d+)$/ do |model, name, id|
  Factory(model.gsub(/\s+/, '_').to_sym, :name => name, :id => id)
end

Given /^(\d+) (#{PLURAL_MODELS_BASED_ON_NAME_REGEXP}) exist with names based on "([^\"]+)" and IDs starting at (\d+)$/ do |count, model, name, id|
  (0...count.to_i).each do |index|
    step(%Q{a #{model.singularize} called "#{name}-#{index+1}" with ID #{id.to_i+index}})
  end
end

Given /^(\d+) (#{PLURAL_MODELS_BASED_ON_NAME_REGEXP}) exist with names based on "([^\"]+)"$/ do |count, model, name|
  (0...count.to_i).each do |index|
    step(%Q{a #{model.singularize} called "#{name}-#{index+1}"})
  end
end

ALL_MODELS_THAT_CAN_HAVE_UUIDS_BASED_ON_ID = [
  'request',
  'library creation request',
  'multiplexed library creation request',
  'sequencing request',

  'user',
  'asset',
  'asset rack',
  'full asset rack',
  'asset rack creation',
  'sample tube',
  'lane',
  'plate',
  'well',
  'pulldown multiplexed library tube',
  'multiplexed library tube',
  'stock multiplexed library tube',

  'asset audit',

  'plate purpose',
  'purpose',
  'dilution plate purpose',
  'bulk transfer',

  'sample',
  'sample manifest',

  'submission',
  'order',

  'batch',

  'tag layout',
  'plate creation',
  'plate conversion',
  'tube creation',
  'state change',

  'aliquot',
  'qcable',
  'stock',
  'stamp',
  'qcable creator',
  'lot',
  'lot type',
  'robot',
  'qc decision',
  'robot',
  'reference genome',
  'transfer'
]

SINGULAR_MODELS_BASED_ON_ID_REGEXP = ALL_MODELS_THAT_CAN_HAVE_UUIDS_BASED_ON_ID.join('|')
PLURAL_MODELS_BASED_ON_ID_REGEXP   = ALL_MODELS_THAT_CAN_HAVE_UUIDS_BASED_ON_ID.map(&:pluralize).join('|')

Given /^a (#{SINGULAR_MODELS_BASED_ON_NAME_REGEXP}|#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) with UUID "([^"]*)" exists$/ do |model,uuid_value|
  set_uuid_for(Factory(model.gsub(/\s+/, '_').to_sym), uuid_value)
end

Given /^the UUID for the last (#{SINGULAR_MODELS_BASED_ON_NAME_REGEXP}|#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) is "([^\"]+)"$/ do |model, uuid_value|
  set_uuid_for(model.gsub(/\s+/, '_').camelize.constantize.last, uuid_value)
end

Given /^the UUID for the (#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) with ID (\d+) is "([^\"]+)"$/ do |model,id,uuid_value|
  set_uuid_for(model.gsub(/\s+/, '_').camelize.constantize.find(id), uuid_value)
end

Given /^all (#{PLURAL_MODELS_BASED_ON_NAME_REGEXP}|#{PLURAL_MODELS_BASED_ON_ID_REGEXP}) have sequential UUIDs based on "([^\"]+)"$/ do |model,core_uuid|
  core_uuid = core_uuid.dup  # Oh the irony of modifying a string that then alters Cucumber output!
  core_uuid << '-' if core_uuid.length == 23
  core_uuid << "%0#{36-core_uuid.length}d"

  model.singularize.gsub(/\s+/, '_').camelize.constantize.all.each_with_index do |object, index|
    set_uuid_for(object, core_uuid % (index+1))
  end
end

Given /^the UUID of the next (#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) created will be "([^\"]+)"$/ do |model,uuid_value|
  model_class = model.gsub(/\s+/, '_').classify.constantize

  next_id = ActiveRecord::Base.connection.execute("SHOW TABLE STATUS WHERE `name` = '#{model_class.table_name}'").first['Auto_increment']

  # Unforunately we need to find the root of the tree
  root_class = model_class
  root_class = root_class.superclass until root_class.superclass == ActiveRecord::Base
  Uuid.new(:resource_type => root_class.sti_name, :resource_id => next_id, :external_id => uuid_value).save(false)
end

Given /^the UUID of the last (#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) created is "([^\"]+)"$/ do |model,uuid_value|
  target = model.gsub(/\s+/, '_').classify.constantize.last or raise StandardError, "There appear to be no #{model.pluralize}"
  target.uuid_object.update_attributes!(:external_id => uuid_value)
end

Given /^(\d+) (#{PLURAL_MODELS_BASED_ON_ID_REGEXP}) exist with IDs starting at (\d+)$/ do |count, model, id|
  (0...count.to_i).each do |index|
    step(%Q{the #{model.singularize} exists with ID #{id.to_i+index}})
  end
end


# TODO: It's 'UUID' not xxxing 'uuid'.
Given /^I have an (event|external release event) with uuid "([^"]*)"$/ do |model,uuid_value|
  set_uuid_for(model.gsub(/\s+/, '_').methodize.camelize.constantize.create!(:message => model), uuid_value)
end

Given /^I have a billing event with UUID "([^\"]+)"$/ do |uuid_value|
  project = Factory :project, :name => "Test Project"
  step(%Q{the project "Test Project" a budget division "Human variation"})
  request = Request.create!(:request_type => RequestType.find_by_key('paired_end_sequencing'))
  request.request_metadata.update_attributes!(:read_length => 100, :library_type => "Standard" )
  billing_event = Factory :billing_event, :project => project, :request => request
  set_uuid_for(billing_event, uuid_value)
end

Given /^a (plate|well) with uuid "([^"]*)" exists$/ do |model,uuid_value|
  set_uuid_for(Factory(model.to_sym), uuid_value)
end

Given /^the (#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) exists with ID (\d+)$/ do |model, id|
  Factory(model.gsub(/\s+/, '_').to_sym, :id => id)
end


Given /^the (#{SINGULAR_MODELS_BASED_ON_ID_REGEXP}) exists with ID (\d+) and the following attributes:$/ do |model, id, table|
  attributes = table.hashes.inject({}) { |h, att|  h.update(att["name"] => att["value"]) }
  attributes[:id] ||= id
  Factory(model.gsub(/\s+/, '_').to_sym, attributes)
end

Given /^a asset_link with uuid "([^"]*)" exists and connects "([^"]*)" and "([^"]*)"$/ do |uuid_value, uuid_plate, uuid_well|
  plate = Plate.find(Uuid.find_id(uuid_plate))
  well  = Well.find(Uuid.find_id(uuid_well))
  set_uuid_for(AssetLink.create!(:ancestor => plate, :descendant => well), uuid_value)
end

Given /^there are (\d+) "([^\"]+)" requests with IDs starting at (\d+)$/ do |count, type, id|
  (0...count.to_i).each do |index|
    step(%Q{a "#{type}" request with ID #{id.to_i+index}})
  end
end

Given /^a "([^\"]+)" request with ID (\d+)$/ do |type, id|
  request_type = RequestType.find_by_name(type) or raise StandardError, "Cannot find request type #{type.inspect}"
  request_type.requests.create! { |r| r.id = id.to_i }
end

Given /^all of the requests have appropriate assets with samples$/ do
  Request.find_each do |request|
    request.update_attributes!(:asset => Factory(request.request_type.asset_type.underscore.to_sym))
  end
end

Given /^plate "([^"]*)" is a source plate of "([^"]*)"$/ do |source_plate_uuid, destination_plate_uuid|
  source_plate = Plate.find(Uuid.find_id(source_plate_uuid))
  destination_plate = Plate.find(Uuid.find_id(destination_plate_uuid))
  source_plate.children << destination_plate
end

Given /^the UUID for well (\d+) on plate "(.*?)" is "(.*?)"$/ do |well_id, plate_name, uuid|
  plate = Plate.find_by_name(plate_name) || Plate.find_by_barcode(plate_name)
  set_uuid_for(plate.wells[well_id.to_i-1],uuid)
end
