class SimpleUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :surname, :avatar, :member_status

  def member_status
    object.attendees.exists?(admin: true) ? 'Host' : 'Member'
  end
end
