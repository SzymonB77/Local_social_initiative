class Member < ApplicationRecord
  
  MEMBER_ROLES = %w[organizer co-organizer member].freeze
  # Add validations
  validates :role, inclusion: { in: MEMBER_ROLES }

  # associations
  belongs_to :user
  belongs_to :group
end