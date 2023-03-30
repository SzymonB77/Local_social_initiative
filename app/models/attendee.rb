class Attendee < ApplicationRecord

    # associations
    belongs_to :user
    belongs_to :event
end
