# frozen_string_literal: true

module ::Collections
  module GuardianExtensions
    def can_change_collection_status?(topic)
      # set to can edit, as this will cover OP and staff.
      # should we need to extend this, ie. as a new permission, we can extend this method
      can_edit_topic?(topic)
    end

    def can_change_collection_index_of_topic?(topic)
      can_edit_topic?(topic)
    end
  end
end