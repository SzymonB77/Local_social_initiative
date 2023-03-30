class AttendeeSerializer < ActiveModel::Serializer
  attributes :id, :admin, :user_id, :event_id
end
