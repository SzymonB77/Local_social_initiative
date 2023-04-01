class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :status, :location, :description

  has_many :users, key: :attendees, serializer: SimpleUserSerializer, limit: 4

end
