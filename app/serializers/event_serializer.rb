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
#
class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :status, :location, :description

  has_many :attendees, serializer: SimpleAttendeeSerializer, limit: 4
end
