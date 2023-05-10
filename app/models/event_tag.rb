# == Schema Information
#
# Table name: event_tags
#
#  id         :bigint           not null, primary key
#  event_id   :bigint           not null
#  tag_id     :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EventTag < ApplicationRecord
  validates :event, presence: true
  validates :tag, presence: true
  validates :event, uniqueness: { scope: %i[event_id tag_id] }
  # associations
  belongs_to :tag
  belongs_to :event
end
