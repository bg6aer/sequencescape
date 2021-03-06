class AddExtendedValidatorsTable < ActiveRecord::Migration

  require './lib/foreign_key_constraint'
  extend ForeignKeyConstraint

  def self.up
    ActiveRecord::Base.transaction do
      create_table :extended_validators do |t|
        t.string :behaviour, :null => false
        t.text  :options
        t.timestamps
      end

      create_table :request_types_extended_validators do |t|
        t.references :request_type, :null =>false
        t.references :extended_validator, :null => false
        t.timestamps
      end

      add_constraint('request_types_extended_validators','request_types')
      add_constraint('request_types_extended_validators','extended_validators')

    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_constraint('request_types_extended_validators','request_types')
      drop_constraint('request_types_extended_validators','extended_validators')

      drop_table :extended_validators
      drop_table :request_types_extended_validators
    end
  end
end
