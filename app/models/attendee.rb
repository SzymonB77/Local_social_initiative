class Attendee < ApplicationRecord
  ATTENDE_ROLES = ["host", "co-host", "member"].freeze
  # Add validations
   validates :role, inclusion: { in: ATTENDE_ROLES }
  
   # associations
    belongs_to :user
    belongs_to :event
end
