# == Schema Information
#
# Table name: attendees
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  event_id   :bigint           not null
#  role       :string           default("member")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Attendee < ApplicationRecord
  ATTENDE_ROLES = %w[host co-host member].freeze
  # Add validations
  validates :role, inclusion: { in: ATTENDE_ROLES }

  # associations
  belongs_to :user
  belongs_to :event
end
