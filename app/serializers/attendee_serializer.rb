class AttendeeSerializer < ActiveModel::Serializer
  attributes :id, :role, :user_id, :event_id
end
