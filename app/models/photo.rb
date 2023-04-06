# == Schema Information
#
# Table name: photos
#
#  id         :bigint           not null, primary key
#  event_id   :bigint
#  user_id    :bigint
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Photo < ApplicationRecord
  # Add validations
  validates :url, presence: true

  # associations
  belongs_to :event
  belongs_to :user
end
