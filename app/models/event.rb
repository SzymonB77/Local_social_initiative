# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  name        :string
#  start_date  :datetime
#  end_date    :datetime
#  status      :string           default("planned")
#  location    :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :bigint
#  main_photo  :string
#
class Event < ApplicationRecord
  
  # Add validations
  validates :name, presence: true
  validates :start_date, presence: true
  validate :start_date_cannot_be_in_the_past, on: :create
  validate :end_date_cannot_be_before_start_date, on: :create

  # associations
  has_many :attendees, dependent: :destroy
  has_many :users, through: :attendees
  belongs_to :group, optional: true
  has_many :event_tags, dependent: :destroy
  has_many :tags, through: :event_tags
  has_many :photos, dependent: :destroy

  def start_date_cannot_be_in_the_past
    errors.add(:start_date, "can't be in the past") if start_date.present? && start_date < Time.zone.now
  end

  def end_date_cannot_be_before_start_date
    errors.add(:end_date, "can't be before start date") if end_date.present? && end_date < start_date
  end
end
