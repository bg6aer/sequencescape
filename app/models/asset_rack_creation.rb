# Creating an instance of this class causes a child plate, with the specified plate type, to be created from
# the parent.
class AssetRackCreation < AssetCreation
  include_plate_named_scope :parent

  # This is the child that is created from the parent.  It cannot be assigned before validation.
  belongs_to :parent, :class_name => 'Asset'
  # named_scope :include_parent, :include => :parent
  named_scope :include_child, :include => :child

  def record_creation_of_children
    parent.events.create_plate!(child_purpose, child, user)
  end
  private :record_creation_of_children

  module Children

    def self.included(base)
      base.class_eval %Q{

        belongs_to :child, :class_name => 'AssetRack'

        validates_unassigned(:child)
      }
    end

    def target_for_ownership
      child
    end
    private :target_for_ownership

    def children
      [self.child]
    end
    private :children

    def create_children!
      self.child = child_purpose.create!(:location=>parent.location,:source=>parent.source_plate)
    end
    private :create_children!

  end
  include Children

end
