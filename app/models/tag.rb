# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  # Add validations
  validates :name, presence: true, uniqueness: true

  # associations
  has_many :event_tags, dependent: :destroy
  has_many :events, through: :event_tags
end
