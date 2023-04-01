class Event < ApplicationRecord
  VALID_STATUSES = ["planned", "in progress", "finished"].freeze
  # Add validations
  validates :name, presence: true
  validates :start_date, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }
  validate :start_date_cannot_be_in_the_past
  validate :end_date_cannot_be_before_start_date


    # associations
    has_many :attendees, dependent: :destroy
    has_many :users, through: :attendees

  def start_date_cannot_be_in_the_past
    if start_date < Time.zone.now
      errors.add(:start_date, "can't be in the past")
    end
  end

  def end_date_cannot_be_before_start_date
    if end_date.present? && end_date < start_date
      errors.add(:end_date, "can't be before start date")
    end
  end
end
