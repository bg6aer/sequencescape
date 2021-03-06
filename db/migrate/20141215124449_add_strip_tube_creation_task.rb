class AddStripTubeCreationTask < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      LabInterface::Workflow.find_by_name!('Strip Tube Creation').tap do |workflow|
        stct = StripTubeCreationTask.create!(
          :name => 'Strip Tube Creation',
          :workflow => workflow,
          :sorted => 1,
          :interactive => true,
          :lab_activity => true
        )
        stct.descriptors.create!(
          :name => 'Strips to create',
          :selection => [1,2,4,6,12],
          :kind => 'Selection',
          :key => 'strips_to_create'
        )
        stct.descriptors.create!(
          :name => 'Strip Tube Purpose',
          :value => 'Strip Tube Purpose',
          :key => 'strip_tube_purpose'
        )
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      LabInterface::Workflow.find_by_name!('Strip Tube Creation').tasks.find_by_name('Strip Tube Creation').destroy
    end
  end
end
