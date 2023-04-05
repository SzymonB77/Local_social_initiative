# == Schema Information
#
# Table name: attendees
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  event_id   :bigint           not null
#  role       :string           default("attendee")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AttendeeSerializer < ActiveModel::Serializer
  attributes :id, :role, :user_id, :event_id
end
