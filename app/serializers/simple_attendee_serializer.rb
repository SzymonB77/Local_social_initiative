class SimpleAttendeeSerializer < ActiveModel::Serializer
  belongs_to :user, key: :attendees, serializer: SimpleUserSerializer

  attributes :member

  def member
    object.admin? ? 'Host' : 'Member'
  end
end
