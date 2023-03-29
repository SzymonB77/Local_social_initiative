class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :status, :location, :description
end
