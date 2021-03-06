#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2014,2015 Genome Research Ltd.
class Api::Messages::FlowcellIO < Api::Base

  MANUAL_QC_BOOLS = {'passed'=>true,'failed'=>false }

  module LaneExtensions # Included in SequencingRequest

    def self.included(base)
      base.class_eval do

        def position
          batch_request.position
        end

        def mx_library
          asset.external_identifier
        end

        def manual_qc
          MANUAL_QC_BOOLS[asset.qc_state]
        end

        def samples
          some_untagged = target_asset.aliquots.any?(&:untagged?)
          target_asset.aliquots.reject do |a|
            (spiked_in_buffer.present? && spiked_in_buffer.primary_aliquot =~ a) or
            some_untagged && a.tagged? # Reproduces behaviour of batch.xml. Needed due to odd legacy data
          end
        end

        delegate :spiked_in_buffer, :external_release, :to=>:target_asset, :allow_nil => true

        def controls
          spiked_in_buffer.present? ? spiked_in_buffer.aliquots : []
        end

        def lane_identifier
          target_asset_id
        end

        def product_line
          return nil if request_type.product_line.nil?
          request_type.product_line.name
        end

      end
    end
  end

  module ControlLaneExtensions
    def self.included(base)
      base.class_eval do

        def position
          batch_request.position
        end

        def mx_library
          asset.external_identifier||"UNKNOWN"
        end

        def manual_qc
          MANUAL_QC_BOOLS[asset.qc_state]
        end

        def samples
          return []
        end

        def product_line
          nil
        end

        def spiked_in_buffer
          false
        end
        def external_release
         false
        end

        def controls
          asset.aliquots
        end

        def lane_identifier
          'control_lane'
        end

      end
    end
  end

  module AliquotExtensions
    module ClassMethods
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        def aliquot_type
          tag.present? ? 'library_indexed' : 'library'
        end

        def control_aliquot_type
          tag.present? ? 'library_indexed_spike' : 'library_control'
        end

        def external_library_id
          library.external_identifier
        end

      end
    end
  end

  module ProjectExtensions
    module ClassMethods
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        def project_cost_code_for_uwh
          project_cost_code.length > 20 ? 'Custom' : project_cost_code
        end
      end
    end
  end

  module Extensions
    module ClassMethods
    end

    def self.included(base)
      base.class_eval do
        extend ClassMethods

        named_scope :including_associations_for_json, { :include => [ :uuid_object, :user, :assignee, { :pipeline => :uuid_object }] }

        def flowcell_barcode
          requests.first.lab_events.each {|e| e.descriptor_value_for("Chip Barcode").tap {|bc| return bc unless bc.nil? } }
          nil
        end

        def read_length
          requests.first.request_metadata.read_length
        end
        # We alias is as the json generator assumes each method is called only once.
        alias :reverse_read_length :read_length

        def lanes; requests; end

      end
    end
  end

  renders_model(::Batch)

  map_attribute_to_json_attribute(:flowcell_barcode)
  map_attribute_to_json_attribute(:id,'flowcell_id')
  map_attribute_to_json_attribute(:read_length,'forward_read_length')
  map_attribute_to_json_attribute(:reverse_read_length,'reverse_read_length')

  map_attribute_to_json_attribute(:updated_at)

  with_nested_has_many_association(:lanes) do # actually requests

    map_attribute_to_json_attribute(:manual_qc)
    map_attribute_to_json_attribute(:position)
    map_attribute_to_json_attribute(:priority)
    map_attribute_to_json_attribute(:mx_library,'id_pool_lims')
    map_attribute_to_json_attribute(:external_release,'external_release')
    map_attribute_to_json_attribute(:lane_identifier, 'entity_id_lims')
    map_attribute_to_json_attribute(:product_line,'team')

    with_nested_has_many_association(:samples) do # actually aliquots

      with_association(:tag) do
        map_attribute_to_json_attribute(:map_id, 'tag_index')
        map_attribute_to_json_attribute(:oligo, 'tag_sequence')
        map_attribute_to_json_attribute(:tag_group_id, 'tag_set_id_lims')
        with_association(:tag_group) do
          map_attribute_to_json_attribute(:name, 'tag_set_name')
        end
      end
      map_attribute_to_json_attribute(:library_type, 'pipeline_id_lims')
      with_association(:bait_library) do
        map_attribute_to_json_attribute(:name, 'bait_name')
      end
      map_attribute_to_json_attribute(:insert_size_from, 'requested_insert_size_from')
      map_attribute_to_json_attribute(:insert_size_to,   'requested_insert_size_to')
      with_association(:sample) do
        map_attribute_to_json_attribute(:uuid, 'sample_uuid')
      end
      with_association(:study) do
        map_attribute_to_json_attribute(:uuid, 'study_uuid')
      end
      with_association(:project) do
        map_attribute_to_json_attribute(:project_cost_code_for_uwh, 'cost_code')
        map_attribute_to_json_attribute(:r_and_d?, 'is_r_and_d')
      end
      map_attribute_to_json_attribute(:external_library_id, 'id_library_lims')
      map_attribute_to_json_attribute(:library_id, 'legacy_library_id')
      map_attribute_to_json_attribute(:aliquot_type,'entity_type')
    end

    with_nested_has_many_association(:controls) do
      with_association(:tag) do
        map_attribute_to_json_attribute(:map_id, 'tag_index')
        map_attribute_to_json_attribute(:oligo, 'tag_sequence')
        map_attribute_to_json_attribute(:tag_group_id, 'tag_set_id_lims')
        with_association(:tag_group) do
          map_attribute_to_json_attribute(:name, 'tag_set_name')
        end
      end
      map_attribute_to_json_attribute(:library_type, 'pipeline_id_lims')
      with_association(:sample) do
        map_attribute_to_json_attribute(:uuid, 'sample_uuid')
      end
      with_association(:study) do
        map_attribute_to_json_attribute(:uuid, 'study_uuid')
      end
      map_attribute_to_json_attribute(:library_id, 'legacy_library_id')
      map_attribute_to_json_attribute(:external_library_id, 'id_library_lims')
      map_attribute_to_json_attribute(:control_aliquot_type,'entity_type')
    end
  end


end


