# frozen_string_literal: true

class CollectionItem < ActiveRecord::Base
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
