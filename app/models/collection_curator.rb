# frozen_string_literal: true

class CollectionCurator < ActiveRecord::Base
  belongs_to :collection
  belongs_to :user

  validates :collection, presence: true
  validates :user, presence: true

end

# == Schema Information
#
# Table name: collection_curators
#
#  id            :integer          not null, primary key
#  collection_id :integer          not null
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null