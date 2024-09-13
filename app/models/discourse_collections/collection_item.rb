# frozen_string_literal: true

module ::DiscourseCollections
  class CollectionItem < ActiveRecord::Base
    self.table_name = 'collection_items'
    VALID_COLLECTABLE_CLASSES = [
      Topic,
      Post
    ]

    belongs_to :collection
    belongs_to :collectable, polymorphic: true

    validates_associated :collection, presence: true
    validates_associated :collectable, presence: true, uniqueness: true
    validates :collectable_type, inclusion: { in: VALID_COLLECTABLE_CLASSES.map(&:name) }
    validates :name, presence: true
    validate :post_must_have_topic_in_collection, if: :is_post?

    def is_topic?
      collectable_type == Topic.name
    end
    
    def is_post?
      collectable_type == Post.name
    end

    def post_must_have_topic_in_collection
      if collection.collection_items.find_by(collectable_type: Topic.name, collectable_id: Post.find(collectable_id).topic_id).nil?
        errors.add(:collectable, "Post must have a topic in the collection")
      end
    end

    before_save :update_topic_custom_field
    before_destroy :remove_topic_custom_field

    private
      def update_topic_custom_field
        if is_topic?
          # topics are unique, so we can just update the custom field
          collectable.update_attribute(IN_COLLECTION.to_sym, true)
        end
      end

      def remove_topic_custom_field
        if is_topic? && collectable.send(IN_COLLECTION).present?
          collectable.update_attribute(IN_COLLECTION.to_sym, false)
        end
      end

      # TODO: add method to delete posts when topics are deleted
  end
end

# == Schema Information
#
# Table name: collection_items
#
#  id                 :integer          not null, primary key
#  collection_id      :integer          not null
#  name               :string
#  collectable_id     :integer          not null
#  collectable_type   :string           not null
#  position           :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
