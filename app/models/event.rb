class Event < ApplicationRecord
  VALID_STATUSES = ["planned", "in progress", "finished"].freeze
  # Add validations
  validates :name, presence: true
  validates :start_date, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }

    # associations
    has_many :attendees, dependent: :destroy
end
