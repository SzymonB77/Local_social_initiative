class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :status, :location, :description

  has_many :attendees, serializer: SimpleAttendeeSerializer, limit: 4

end
