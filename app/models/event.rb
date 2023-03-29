class Event < ApplicationRecord
  VALID_STATUSES = ["planned", "in progress", "finished"].freeze
  # Add validations
  validates :name, presence: true
  validates :start_date, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }
end
