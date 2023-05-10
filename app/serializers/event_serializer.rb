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
class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :status, :location, :description, :hosted_by

  has_many :attendees, serializer: SimpleAttendeeSerializer, limit: 4
  has_many :photos, serializer: PhotoSerializer, limit: 4
  belongs_to :group
  has_many :tags

  def hosted_by
    host = object.attendees.find_by(role: 'host')
    SimpleAttendeeSerializer.new(host).attributes if host
  end
end
