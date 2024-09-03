# frozen_string_literal: true

module ::DiscourseCollections
  class Collection < ActiveRecord::Base
    self.table_name = 'collections'
    belongs_to :user, class_name: 'User'
    has_many :collection_items, -> { order(:position) }, dependent: :destroy
    has_many :collection_curators, dependent: :destroy

    validates :user, presence: true
    validates :title, presence: true
    # validates :user, exclusion: { in: ->(curators) { [curators.user] } }

    # def curators
    #   User.where(id: collection_curators.pluck(:user_id))
    # end
  end
end

# == Schema Information
#
# Table name: collections
#
#  id             :integer          not null, primary key
#  title          :string
#  description    :text             default("")
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
