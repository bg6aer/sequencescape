#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2014 Genome Research Ltd.
##
# A lot represents a received batch of consumables (eg. tag plates)
# that can be assumed to share some level of QC.

class Lot < ActiveRecord::Base

  module Template
    def self.included(base)
      base.class_eval do
        belongs_to :lot
      end
    end
  end

  # include Api::LotIO::Extensions
  include Uuid::Uuidable

  belongs_to :lot_type
  belongs_to :user
  belongs_to :template, :polymorphic => true

  has_many :qcables, :inverse_of => :lot

  has_many :stamps, :inverse_of => :lot

  validates_presence_of :lot_number, :lot_type, :user, :template, :received_at
  validates_uniqueness_of :lot_number

  validate :valid_template?

  delegate :valid_template_class, :target_purpose, :to => :lot_type

  named_scope :include_lot_type, { :include => :lot_type }
  named_scope :include_template, { :include => :template }
  named_scope :with_lot_number, lambda { |lot_number| {:conditions=>{:lot_number=>lot_number} } }

  named_scope :with_qc_asset, lambda {|qc_asset|
    return { :conditions => 'FALSE' } if qc_asset.nil?
    sibling = qc_asset.transfers_as_destination.first.source

    {:include=>:qcables,:conditions=>['qcables.asset_id IN(?) AND qcables.state != ?',[qc_asset.id,sibling.id],'exhausted' ]}
  }

  private

  def valid_template?
    return false unless lot_type.present?
    return true if template.is_a?(valid_template_class)
    errors.add(:template,"is not an appropriate type for this lot. Received #{template.class} expected #{valid_template_class}.")
    false
  end

end
